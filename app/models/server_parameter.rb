
class ServerParameter < BaseModel
    belongs_to :server

    validates_presence_of :name, :value
    validates_format_of   :name, :with => /\A\w[\w\.\-_]+\z/,
        :message => "use only letters, numbers, and .-_ please."
	validates_uniqueness_of :name, :scope => :server_id

    attr_accessor :should_destroy

    def should_destroy?
        should_destroy.to_i == 1
    end
end
