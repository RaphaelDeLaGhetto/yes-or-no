require 'bcrypt'
class Agent < ActiveRecord::Base
  validates_presence_of :email
  validates_uniqueness_of :email
  has_and_belongs_to_many :ips
  has_many :votes

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, :format => { with: VALID_EMAIL_REGEX }

  attr_accessor :password, :password_confirmation
  validates_presence_of :password
  validates_confirmation_of :password
  validates_presence_of :password_confirmation

  # agent.password_hash in the database is a :string
  include BCrypt

  def password=(new_password)
    if new_password.blank?
      @password = nil
      self.errors.add(:password, :blank, message: "can't be blank")
      return
    end
    @password = Password.create(new_password)
    self.password_hash = @password
  end
end
