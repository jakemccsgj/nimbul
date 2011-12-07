class AddUserKeysCounterCacheColumn < ActiveRecord::Migration
  def self.up
    add_column :users, :user_keys_count, :integer, :default => 0

    User.reset_column_information
    User.find(:all).each do |u|
      User.update_counters u.id, :user_keys_count => u.user_keys.size
    end
  end

  def self.down
    remove_column :users, :user_keys_count
  end
end
