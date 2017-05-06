require 'will_paginate/array'
class Post < ActiveRecord::Base
  #self.per_page = 10

  validates_presence_of :url
  validates_uniqueness_of :url
  validates_presence_of :tag
  validates_length_of :tag, maximum: 256 
  belongs_to :ip
  belongs_to :agent
  has_many :votes, dependent: :destroy

  def answer_yes
    if self.approved
      self.yeses += 1
      self.save
    else
      self.errors.add(:approved, :false, message: "Post has not been approved")
    end
  end

  def answer_no
    if self.approved
      self.nos += 1
      self.save
    else
      self.errors.add(:approved, :false, message: "Post has not been approved")
    end
  end

  #
  # A four-star rating based on total yeses and nos
  #
  def rating
    total_votes = self.yeses + self.nos
    return 0 if total_votes == 0
    (100 * self.yeses) / total_votes
  end

  #
  # 2017-4-18
  #
  # Keep an eye on this. Something stinks
  #
  def self.order_by_rating(page=1)
    Post.where(approved: true).sort_by(&:rating).reverse.paginate(page: page)
    # Alternatively, I could sort descending on yeses and ascending on nos. If the above
    # doesn't pan out, try that
  end
end
