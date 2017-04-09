class Ip < ActiveRecord::Base
  validates_presence_of :address
  has_many :votes
  has_and_belongs_to_many :agents
end
