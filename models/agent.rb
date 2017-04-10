class Agent < ActiveRecord::Base
  validates_presence_of :email
  validates_uniqueness_of :email
  has_and_belongs_to_many :ips
  has_many :votes

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, :format => { with: VALID_EMAIL_REGEX }

  validates :password, :presence => true, :confirmation => true
  validates :password_confirmation, presence: true
end
