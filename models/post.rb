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
end
