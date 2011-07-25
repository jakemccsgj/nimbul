class ServerStat < ActiveRecord::Base
  belongs_to :cluster
  belongs_to :server

  attr_accessor :zone
  def count
    instance_count
  end
end
