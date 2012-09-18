class AddTaggingColumnsToCluster < ActiveRecord::Migration
  def self.up
    change_table :clusters do |t|
      t.column :tag_group, :string, :limit => 128
      t.column :tag_env,   :string, :limit => 128
    end
  end

  def self.down
    change_table :clusters do |t|
      t.remove_column :tag_group
      t.remove_column :tag_env
    end
  end
end
