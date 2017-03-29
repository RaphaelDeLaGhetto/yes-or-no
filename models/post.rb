class Post < ActiveRecord::Base
  validates_presence_of :url
  validates_uniqueness_of :url
  validates_presence_of :tag
  validates_length_of :tag, maximum: 50 

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
    (4 * self.yeses) / total_votes
  end

  def self.order_by_rating(page=1)
    Post.where(approved: true).page(page).sort_by(&:rating).reverse 
  end
end
