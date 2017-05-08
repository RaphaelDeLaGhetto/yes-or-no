require 'bcrypt'
class Agent < ActiveRecord::Base
  validates_presence_of :email
  validates_uniqueness_of :email
  has_and_belongs_to_many :ips
  has_many :votes
  has_many :posts

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, :format => { with: VALID_EMAIL_REGEX }

  # agent.password_hash in the database is a :string
  include BCrypt

  def password
    return nil if !password_hash.present?
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def confirmation
    @confirmation ||= Password.new(confirmation_hash)
  end

  def confirmation=(new_confirmation)
    @confirmation = Password.create(new_confirmation)
    self.confirmation_hash = @confirmation
  end

  def can_vote?(post)
    post.present? && !post.id.nil? && post.agent != self && self.votes.find_by(post_id: post.id).nil?
  end

  def vote(yes, post)
    self.votes.create(yes: yes, post: post) if self.can_vote? post 
  end

  def tally_points
    self.posts.where(approved: true).inject(0){|sum, post| sum += 10 + 3 * post.yeses - post.nos} 
  end
end
