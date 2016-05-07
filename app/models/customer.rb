class Customer < ActiveRecord::Base
  has_many :rates
  has_many :agents, :through => :rates
end
