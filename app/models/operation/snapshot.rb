require "models/volume"
require "models/ec2_adapter"

class Operation::Snapshot < Operation
  private
  step_errors = {}

  public
  def self.label
    'EBS Snapshot'
  end

  def self.is_schedulable?
    true
  end  

  def timeout
    5.minutes
  end

  def steps()
    steps = []
    steps += pre_snapshot_steps || []
    steps += [ snapshot_step ].compact.flatten
    steps += post_snapshot_steps || []
    steps
  end
  
  def pre_snapshot_steps() nil; end
  def post_snapshot_steps() nil; end
  
  def snapshot_step
    steps = CloudVolume.find_all_by_instance_id(instance.id).collect do |vol|
      Operation::Step.new('create_ebs_snapshot') do
        snapshot = vol.snapshot!
        error = snapshot.nil? ? "There was an error creating the snapshot: #{vol.errors.collect{|attr,msg| "#{attr} - #{msg}" }.join("; ")}" \
              :                  nil
        self.step_errors[vol.name] = error
  
        self[:result_code] =  \
          case self.step_errors.values.count(nil)
            when self.step_errors.count then 'Success'
            when 0            then 'Failure'
            else              'Partial Success'
          end
        self[:result_message] = "Created #{self.step_errors.values.count(nil)} / #{self.step_errors.count} snapshots"
        operation_logs << OperationLog.new(
          :step_name => "create_ebs_snapshot: #{vol.name}",
          :is_success => error.nil?,
          :result_code => error.nil? ? 'Success' : 'Failure',
          :result_message => error.nil? ? "Created snapshot #{snapshot.name}" : error
        )

        #(self.step_errors.values.count(nil) == self.step_errors.count) ? wait! : fail!
      end
    end
    proceed! if can_proceed?
    steps
  end
end
