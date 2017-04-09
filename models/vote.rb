class Vote < ActiveRecord::Base
  belongs_to :agent
  belongs_to :post
  belongs_to :ip
  validates_presence_of :post
  validates_uniqueness_of :post_id, :scope => [:agent_id, :ip_id]

  validate :agent_xor_post

  after_save :register_vote

  private

    # Vote belongs to an agent or an IP. Not both  
    def agent_xor_post
      unless agent.nil? ^ ip.nil?
        errors.add(:base, "Vote must belong to an agent or an IP, but not both")
      end
    end

    def register_vote
      if self.post
        if self.yes
          self.post.answer_yes
        else
          self.post.answer_no if !self.yes
        end
      end
    end
end
