require 'attr_encrypted'

class ProviderAccountKey < ActiveRecord::Base
  belongs_to :provider_account
  attr_encrypted :value, :key => '1241rdcadscvjwe0v13jrf1', :algorithm => 'aes-256-ecb'
end
