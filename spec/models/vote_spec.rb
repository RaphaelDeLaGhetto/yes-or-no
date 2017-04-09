require 'spec_helper'

RSpec.describe Vote do
  context 'database schema', type: :model do
    describe 'columns' do
      it { should have_db_column(:id) }
      it { should have_db_column(:ip_id) }
      it { should have_db_column(:agent_id) }
      it { should have_db_column(:yes) }
      it { should have_db_column(:created_at) }
      it { should have_db_column(:updated_at) }
    end
  end

  context 'validations' do
    subject { Vote.new }
    it { should validate_presence_of(:post) }
    it { should validate_uniqueness_of(:post_id).scoped_to([:agent_id, :ip_id]) }

    it "ensures either ip or agent is set" do
      agent = create(:agent)
      vote = Vote.new
      vote.post = create(:post)
      vote.yes = true

      expect(vote.valid?).to be_falsey
      vote.agent = agent
      expect(vote.valid?).to be_truthy
      vote.agent = nil 
      expect(vote.valid?).to be_falsey
      vote.ip = create(:ip)
      expect(vote.valid?).to be_truthy
      vote.agent = agent
      expect(vote.valid?).to be_falsey
    end
  end

  context 'relationships' do
    subject { Vote.new }
    it { should belong_to(:agent) }
    it { should belong_to(:ip) }
    it { should belong_to(:post) }
  end

  context 'after_save' do
    before :each do
      @post = create(:post, approved: true)
      @vote = Vote.new(post: @post)
    end

    context 'agent vote' do
      before :each do
        @agent = create(:agent)
        @vote.agent = @agent
      end

      it "increments the post's yeses for a yes vote " do
        expect(@post.yeses).to eq(0)
        @vote.yes = true 
        @vote.save 
        expect(Post.find(@post.id).yeses).to eq(1)
      end
  
      it "increments the post's nos for a no vote" do
        expect(@post.nos).to eq(0)
        @vote.yes = false 
        @vote.save 
        expect(Post.find(@post.id).nos).to eq(1)
      end
    end

    context 'ip vote' do
      before :each do
        @ip = create(:ip)
        @vote.ip = @ip
      end

      it "increments the post's yeses for a yes vote " do
        expect(@post.yeses).to eq(0)
        @vote.yes = true 
        @vote.save 
        expect(Post.find(@post.id).yeses).to eq(1)
      end
  
      it "increments the post's nos for a no vote" do
        expect(@post.nos).to eq(0)
        @vote.yes = false 
        @vote.save 
        expect(Post.find(@post.id).nos).to eq(1)
      end
    end
  end
end
