class Agent < ActiveRecord::Base
  has_many :rates
  has_many :customers, :through => :rates
end
