require 's3_adapter'

class Publisher::InstanceList < Publisher
  include Resque::Plugins::UniqueJob
  @loner_ttl = 300
  @queue = :instancelist_publishers

  URL_PARAM_NAME = 'INSTANCES_FILE_URL'

  before_destroy :remove_url_parameter

  def description
    'Publishes a list of instances (all active instances, regardless of maintenance mode state) suitable for services to utilize (Hudson, ec2_toolkit, etc)'
  end

  def initialize_parameters
    parameters = []
    parameters << PublisherParameter.new({
      :name => 's3_bucket_name',
      :control_type => 'text_field',
    })
    parameters << PublisherParameter.new({
      :name => 's3_object_name',
      :control_type => 'text_field',
    })
    return parameters
  end

  def is_configuration_good?
    account = ProviderAccount.find(self.provider_account_id, :include => [ :clusters ])
    bucket = parameter_value('s3_bucket_name')
    base_path = parameter_value('s3_object_name')

    if bucket.blank? or base_path.blank?
      self.state = "failure"
      self.state_text = "Missing parameters bucket name and/or object name"
      return false
    end

    begin
      S3Adapter.create_bucket(account, bucket)
      self.state = "success"
      self.state_text = "Successfully accessed bucket '#{bucket}'"
    rescue
      self.state = "failure"
      self.state_text = "Publisher invalid: #{$!}"
      return false
    end

    return true
  end

  def publish!
    account = ProviderAccount.find(self.provider_account_id, :include => { :clusters => :servers } )
    logger.debug "Running InstanceList publisher for account: #{account.id}"
    return unless account.aws_access_key and account.aws_secret_key
    bucket = parameter_value('s3_bucket_name')
    base_path = parameter_value('s3_object_name')

    begin
      hostfile = <<-EOF
# Published by InstanceList Publisher on #{Time.now.to_s}

#{DnsAdapter.get_host_entries provider_account, :format => :all_instances}
      EOF

      S3Adapter.put_object(account, bucket, base_path, hostfile, 'public-read')

      account.set_provider_account_parameter(URL_PARAM_NAME , s3_url_for(bucket, provider_path), true)

      update_attributes({
        :last_published_at => Time.now,
        :state => 'success',
        :state_text => s3_url_for(bucket, provider_path)
      })
    rescue Exception => e
      raise
      logger.error "Failed to publish InstanceList for #{account.id}: #{e}"
      update_attributes({
        :state => 'failed',
        :state_text => "Error: <pre>#{e.message}\n\t#{e.backtrace.join("\n\t")}</pre>",
      })
      return false
    end

    true
  end

  def self.label
    "InstanceList"
  end

  protected

  def s3_url_for(bucket, path='')
    return nil if bucket.nil?
    return "http://#{bucket}.s3.amazonaws.com/#{path}"
  end

  def remove_url_parameter
    param = ProviderAccount.find(self.provider_account_id).provider_account_parameters.detect { |p| p.name == URL_PARAM_NAME }
    param.destroy unless param.nil?
  end

end
