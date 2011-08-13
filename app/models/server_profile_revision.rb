class ServerProfileRevision < BaseModel
  belongs_to :server_profile
  belongs_to :creator, :class_name => 'User'
  belongs_to :instance_vm_type
  belongs_to :server_image
  
  has_many :servers
  has_many :server_profile_revision_parameters, :order => "position"
  
  validates_presence_of :revision, :creator_id, :commit_message
  validates_presence_of :server_image_id, :instance_vm_type_id
  
  after_save :save_server_profile_revision_parameters
  
  attr_accessor :should_destroy

  def should_destroy?
    should_destroy.to_i == 1
  end
  
  attr_accessor :status_message

  def instance_type
    return nil if self.instance_vm_type.nil?
    return self.instance_vm_type.api_name
  end

  def image_id
    return nil if server_image.nil?
    return server_image.image_id
  end

  def is_head?
    revision == 0
  end

  def to_s
    server_profile.name + (is_head? ? " [HEAD]" : " [Rev #{revision}]")
  end

  def server_profile_revision_parameter_attributes=(server_profile_revision_parameter_attributes)
    server_profile_revision_parameter_attributes.each do |attributes|
      if attributes[:id].blank?
        server_profile_revision_parameters.build(attributes)
      else
        server_profile_revision_parameter = server_profile_revision_parameters.detect { |c| c.id == attributes[:id].to_i }
        server_profile_revision_parameter.attributes = attributes unless server_profile_revision_parameter.nil?
      end
    end
  end

  def save_server_profile_revision_parameters
    server_profile_revision_parameters.each do |c|
      if c.should_destroy?
        c.destroy
      else
        c.save(false)
      end
    end
  end

  #
  # sort, search and paginate parameters
  #
  def self.per_page
    10
  end

  def self.sort_fields
    %w(name server_image_id)
  end

  def self.search_fields
    %w(name server_image_id)
  end
end
