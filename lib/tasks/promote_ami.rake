require 'aws'

namespace :ami do
  desc "Promote an AMI from one account to another.  Defaults to promotion from the staging account to the production account"
  task :promote, [:image] => [:environment] do |t, args|
    source_account = ProviderAccount.find_by_account_id (ENV['SOURCE_ACCOUNT'] || '155565490060') # Default to stg
    target_account = ProviderAccount.find_by_account_id (ENV['TARGET_ACCOUNT'] || '771521388140') # Default to prd
    promote source_account, target_account, args[:image]
  end
end

def promote source, target, image_id
      ec2 = Aws::Ec2.new source.aws_access_key, source.aws_secret_key

      puts "Finding #{image_id} in #{source.name}..."

      image = ec2.ec2_describe_images({:ImageId => image_id, :Owner => source.account_id})
      if image.empty?
        puts "AMI #{image_id} not found or not owned by account #{source.account_id}"
        exit 1
      end

      puts "Sharing image to #{target.name}"
      ec2.modify_image_launch_perm_add_users(image_id, [target.account_id])

      puts "Adding image to target account in Nimbul"
      source_image = ServerImage.find_by_image_id(image_id)
      target_image = source_image.clone
      target_image.provider_account = target
      target_image.save!

      puts "Complete"
end
