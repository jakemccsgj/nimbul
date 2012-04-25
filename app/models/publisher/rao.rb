class Publisher::Rao < Publisher::Nagios
  include Resque::Plugins::UniqueJob
  @queue = :rao_publishers
  def description
    "Publishes list of instances with DNS information and roles. Doesn't care about the Maintenance flag."
  end

  def self.label
    "Rao"
  end

  def publish!
    account = ProviderAccount.find(self.provider_account_id, :include => { :clusters => :servers })
    bucket = parameter_value('s3_bucket_name')
    base_path = parameter_value('s3_object_name')

    begin
      urls = []
      intro = "# Published by Rao Publisher on "+Time.now.to_s+"\n"

      # collect entries including roles but skip all the down instances
      hostfile = intro + DnsAdapter.get_host_entries(provider_account, { :format => :nagios, :include_all_clusters => true })
      S3Adapter.put_object(account, bucket, base_path, hostfile, 'public-read')

      urls << base_path
      urls.collect!{ |p| "<a href='#{s3_url_for(bucket,p)}' target=_new>#{s3_url_for(bucket,p)}</a>" }
      
      update_attributes({
        :last_published_at => Time.now,
        :state => 'success',
        :state_text => urls.join('<br />')
      })
    rescue Exception => e
      update_attributes({
        :state => 'failed',
        :state_text => "Error: <pre>#{e.message}\n\t#{e.backtrace.join("\n\t")}</pre>",
      })
      return false
    end

    return true
  end

end
