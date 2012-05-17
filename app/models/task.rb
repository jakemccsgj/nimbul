class Task < BaseModel
    LOOP_SLEEP = 60
    include Loggable

    belongs_to :parent, :polymorphic => true
    belongs_to :taskable, :polymorphic => true
    has_many :task_parameters, :dependent => :destroy
    has_many :operations, :dependent => :nullify

    # auditing
    has_many :audit_logs, :as => :auditable, :dependent => :nullify

    validates_presence_of :name
    validates_associated :task_parameters

    validate :repeatable_must_have_run_every_value

    def repeatable_must_have_run_every_value
        errors.add_to_base("Must specify how often to Repeat") if is_repeatable? and (run_every_value.blank? or run_every_value <=0)
    end

    before_save  :set_run_at, :set_run_every
    after_update :save_task_parameters

    attr_accessor :should_destroy, :run_every, :state_text, :scheduler_tag, :new_operations
    
    include TrackChanges # must follow any before filters

    def run_every
        return nil unless is_repeatable?
        "#{self.run_every_value}#{self.run_every_units[0,1]}"
    end

    def should_destroy?
        should_destroy.to_i == 1
    end

    def set_run_at
        if self.run_at.blank? and self.is_repeatable?
            self.run_at = Chronic.parse("#{self.run_in_value} #{self.run_in_units} from now")
        end
    end

    def set_run_every
        unless is_repeatable?
            self.run_every_value = nil
            self.run_every_units = nil
        end
    end

    def save_task_parameters
        task_parameters.each do |i|
            if i.should_destroy?
                i.destroy
            else
                i.save(false)
            end
        end
    end

    def task_parameter_attributes=(task_parameter_attributes)
        task_parameter_attributes.each do |attributes|
            if attributes[:id].blank?
                task_parameters.build(attributes)
            else
                task_parameter = task_parameters.detect { |c| c.id == attributes[:id].to_i }
                task_parameter.attributes = attributes
            end
        end
    end

    def get_parameter(name)
        self.initialize_parameters.detect{|p| p.name == name}
    end

    def parameter_value(name)
        parameter = task_parameters.detect{|p| p.name == name}
        if parameter.nil?
            return nil
        else
            return parameter.value
        end
    end

    def initialize_parameters
        return self.get_operation.initialize_parameters
    end
    
    def options(name)
        []
    end

    def scheduler_tag
        "task_#{self.id}"
    end
    
    def call(job)
        run!
    end

    def get_operation
        op = Operation.factory(self.operation)
        op.task_id = self.id
        return op
    end

    def self.search_by_server(server, search, page, extra_joins, extra_conditions, sort=nil, filter=nil, include=nil)
        search_by_taskable(server, search, page, extra_joins, extra_conditions, sort, filter, include)
    end

    def self.search_by_taskable(taskable, search, page, extra_joins, extra_conditions, sort=nil, filter=nil, include=nil)
        joins = []
        joins = joins + extra_joins unless extra_joins.blank?

        conditions = [ 'taskable_id = ? AND taskable_type = ?', (taskable.is_a?(Integer) ? taskable : taskable.id), taskable.class.to_s ]
        unless extra_conditions.blank?
            extra_conditions = [ extra_conditions ] if not extra_conditions.is_a? Array
            conditions[0] << ' AND ' + extra_conditions[0];
            conditions << extra_conditions[1..-1]
        end

        search(search, page, joins, conditions, sort, filter, include)
    end
    
    # sort, search and paginate parameters
    def self.per_page
        10
    end

    def self.sort_fields
        %w(name)
    end

    def self.search_fields
        %w(name)
    end
    
    def self.filter_fields
        %w(status owner_id)
    end
    
    def run!
        instances = Instance.find_all_by_parent(self.taskable)
        
        begin
            instances.each do |instance|
                next if not instance.running?
                operation = get_operation
                instance.operations << operation
                # store to return to the ui
                self.new_operations = [] if self.new_operations.nil?
                self.new_operations << operation
            end
        rescue
            self.state_text = "Task failed: #{$!}"
            return false
        end
        return true
    end

    class << self
      def process
        # Initialize the Scheduler
        $scheduler = Rufus::Scheduler.start_new

        loop do
          logger.warn "Task daemons is still running"
          # Mark all active task 'unscheduled', in case there was a crash
          Task.update_all( ['is_scheduled=?', 0], { :is_active => 1, :is_scheduled => 1 } )
  
          Signal.trap("TERM") do 
            # Unschedule all the tasks
            $scheduler.all_jobs.map { |id, job| job.unschedule }
            Task.update_all( ['is_scheduled=?', 0], { :is_active => 1, :is_scheduled => 1 } )
          end
  
          # unschedule all non-active tasks
          unschedule_tasks = self.find_all_by_is_active_and_is_scheduled( false, true )
          unschedule_tasks.each do |t|
            $scheduler.find_by_tag(t.scheduler_tag).each do |job|
              job.unschedule
            end
            t.update_attribute( :is_scheduled, false )
            logger.info "Unscheduled Task #{t.name} [#{t.id}]\n"
          end
  
          # unschedule all one-time tasks with run_at in the past
          unschedule_tasks = self.find_all_by_is_active_and_is_scheduled_and_is_repeatable( true, true, false )
          unschedule_tasks.each do |t|
            if t.run_at < Time.now.utc
              $scheduler.find_by_tag(t.scheduler_tag).each do |job|
                job.unschedule
              end
              t.update_attributes( { :is_active => false, :is_scheduled => false } )
              logger.info "Unscheduled Task #{t.name} [#{t.id}]\n"
            end
          end
  
          # schedule all active tasks
          schedule_tasks = self.find_all_by_is_active_and_is_scheduled( true, false )
          schedule_tasks.each do |t|
            # make sure we haven't scheduled the task already
            logger.info("Before iterating is this tag there? #{t.scheduler_tag} == #{$scheduler.find_by_tag(t.scheduler_tag)}")
            if $scheduler.find_by_tag(t.scheduler_tag).length == 0
              if t.is_repeatable?
                # repeatable tasks - make sure first_at is in the future
                # otherwise scheduler will schedule all the "missed" runs
                first_at = t.run_at
                while first_at < Time.now.utc
                  first_at = first_at + Rufus.parse_time_string(t.run_every)
                end
                $scheduler.every t.run_every, :first_at => first_at, :tags => t.scheduler_tag do |job|
                  t.call(job)
                end
              else
                # non-repeatable tasks - only schedule if the run_at time is in the future
                if t.run_at > Time.now.utc
                  $scheduler.at t.run_at, :tags => t.scheduler_tag do |job|
                    t.call(job)
                  end
                end
              end
              logger.info "Scheduled Task #{t.name} [#{t.id}]\n"
            else
              logger.info "Task #{t.name} is already in the scheduler"
            end
            # mark the task as scheduled
            t.update_attribute( :is_scheduled, true )
          end
          logger.info "Tasks in scheduler: \n#{$scheduler.jobs.collect { |i, j| "#{i} => #{j.tags}" }.join("\n")}"
  
          logger.info "Sleeping for #{LOOP_SLEEP} now"
          sleep LOOP_SLEEP
        end
        $scheduler.join
      end
      alias :perform :process

      def queue
        :tasks
      end
    end
end
