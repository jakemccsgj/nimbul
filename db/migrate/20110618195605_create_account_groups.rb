class CreateAccountGroups < ActiveRecord::Migration
  def self.up
    create_table :account_groups do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
    create_table :account_groups_provider_accounts, :id => false do |t|
      t.integer :account_group_id
      t.integer :provider_account_id
    end
    add_index :account_groups_provider_accounts, :account_group_id
    add_index :account_groups_provider_accounts, :provider_account_id
  end

  def self.down
    drop_table :account_groups_provider_accounts 
    drop_table :account_groups
  end
end
