class FixTextSizeOnAccountKeys < ActiveRecord::Migration
  def self.up
    change_column :provider_account_keys, :encrypted_value, :text
  end

  def self.down
    change_column :provider_account_keys, :type, :string
  end
end
