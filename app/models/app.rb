class App < ActiveRecord::Base
    belongs_to :account_group
    has_many :clusters, :dependent => :nullify, :order => :name

    validates_presence_of :account_group_id, :api_name, :name
    validates_uniqueness_of :api_name, :name, :scope => :account_group_id
end
