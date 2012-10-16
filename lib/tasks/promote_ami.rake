require 'aws'

namespace :ami do
  namespace :promote do
    desc "Promote an AMI from the staging account to the production account"
    task :to_prod, [:image] => [:environment] do |t, args|
      source_account = ProviderAccount.find_by_account_id '155565490060'
      target_account = ProviderAccount.find_by_account_id '771521388140'
      promote source_account, target_account, args[:image]
    end
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
