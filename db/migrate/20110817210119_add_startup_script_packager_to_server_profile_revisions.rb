class AddStartupScriptPackagerToServerProfileRevisions < ActiveRecord::Migration
  def self.up
    add_column :server_profile_revisions, :startup_script_packager, :string, :default => 'nimbul'
  end

  def self.down
    remove_column :server_profile_revisions, :startup_script_packager
  end
end
