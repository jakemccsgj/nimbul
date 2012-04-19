class CreateAccountGroups < ActiveRecord::Migration
  def self.up
    create_table :account_groups do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
    add_column :provider_accounts, :account_group_id, :integer
    add_index :provider_accounts, :account_group_id
  end

  def self.down
    drop_table :account_groups_provider_accounts 
    drop_table :account_groups
  end
end
