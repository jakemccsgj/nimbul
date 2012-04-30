class CreateProviderAccountKeys < ActiveRecord::Migration
  def self.up
    create_table :provider_account_keys do |t|
      t.column :encrypted_value, :string
      t.column :type, :string
      t.references :provider_account
      t.timestamps
    end
  end

  def self.down
    drop_table :provider_account_keys
  end
end
