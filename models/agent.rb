class Agent < ActiveRecord::Base
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_presence_of :password
  has_and_belongs_to_many :ips
  has_many :votes

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, :format => { with: VALID_EMAIL_REGEX }
end
