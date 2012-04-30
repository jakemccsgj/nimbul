require 'attr_encrypted'

class ProviderAccountKey < ActiveRecord::Base
  belongs_to :provider_account
  attr_encrypted :value, :key => APP_CONFIG['keystore_key'], :algorithm => 'aes-256-ecb'
end
