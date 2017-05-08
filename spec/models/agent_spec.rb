require 'spec_helper'

RSpec.describe Agent, type: :model do

  context 'database schema' do
    describe 'columns' do
      it { should have_db_column(:id) }
      it { should have_db_column(:name) }
      it { should have_db_column(:email) }
      it { should have_db_column(:password_hash) }
      it { should have_db_column(:confirmation_hash) }
      it { should have_db_column(:created_at) }
      it { should have_db_column(:updated_at) }
    end
  end

  context 'validations' do
    subject { build(:agent) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
  end

  context 'relationships' do
    subject { Agent.new }
    it { should have_many(:votes) }
    it { should have_many(:posts) }
    it { should have_and_belong_to_many(:ips) }
  end

  describe "email address" do
    before :each do
      @agent = create(:agent) 
    end

    it 'valid' do
      adresses = %w[thor@marvel.de hero@movie.com]
      adresses.each do |email|
        @agent.email = email
        expect(@agent.valid?).to be_truthy
      end
    end

    it 'not valid' do
      adresses = %w[spamspamspam.de heman,test.com]
      adresses.each do |email|
        @agent.email = email
        expect(@agent.valid?).to be_falsey
      end
    end
  end

  describe 'password' do
    before :each do
      @agent = build(:agent) 
    end

    it 'encrypts the password' do
      expect(@agent.password).to eq('secret');
      expect(@agent.password_hash).to match(/\$2a\$10\$/);
    end
  end

  describe 'confirmation' do
    before :each do
      @agent = build(:agent) 
    end

    it 'encrypts the confirmation code' do
      expect(@agent.confirmation_hash).to eq(nil);
      @agent.confirmation = 'abc123'
      expect(@agent.confirmation_hash).to match(/\$2a\$10\$/);
      expect(@agent.confirmation == 'abc123').to eq(true)
    end
  end

  describe '#can_vote?' do
    before :each do
      @agent = create(:agent) 
      @post = build(:post)
    end

    it 'returns false if agent has already voted' do
      @post.save
      @agent.vote false, @post
      expect(@agent.can_vote? @post).to eq(false)
    end

    it 'returns false if post belongs to agent' do
      @post.agent = @agent
      @post.save
      expect(@agent.can_vote? @post).to eq(false)
    end

    it 'returns false if post doesn\'t exist' do
      expect(@post.id).to be_nil 
      expect(@agent.can_vote? @post).to eq(false)
    end

    it 'returns true if agent has not voted' do
      @post.save
      expect(@post.agent).not_to eq(@agent)
      expect(@agent.can_vote? @post).to eq(true)
    end
  end

  describe '#vote' do
    before :each do
      @agent = create(:agent) 
    end

    context 'has not voted' do
      before :each do
        @post = create(:post, approved: true)
        expect(Vote.count).to eq(0)
        expect(@agent).not_to eq(@post.agent)
        @agent.vote true, @post
        @post = Post.first
      end

      it 'creates a vote record for the agent' do
        expect(Vote.count).to eq(1)
        vote = Vote.first
        expect(vote.agent).to eq(@agent)
        expect(vote.post).to eq(@post)
        expect(vote.yes).to eq(true)
      end
  
      it 'creates a vote record for the agent' do
        vote = Vote.first
        @agent = Agent.first
        expect(@agent.votes[0]).to eq(vote)
      end
 
      it 'creates a vote record for the post' do
        vote = Vote.first
        @post = Post.first
        expect(@post.votes[0]).to eq(vote)
      end
  
      it 'increments the post\'s vote count' do
        @post = Post.first
        expect(@post.yeses).to eq(1)
        expect(@post.nos).to eq(0)
      end

      context 'has voted' do
        it 'does not create a new vote record' do
          expect(Vote.count).to eq(1)
          @agent.vote false, @post
          expect(Vote.count).to eq(1)
        end
 
        it 'does not create another vote record for the agent' do
          expect(@agent.votes.count).to eq(1)
          @agent.vote false, @post
          @agent = Agent.first
          expect(@agent.votes.count).to eq(1)
        end
    
        it 'does not create another vote record for the post' do
          expect(@post.votes.count).to eq(1)
          @agent.vote false, @post
          @post = Post.first
          expect(@post.votes.count).to eq(1)
        end
    
        it 'does not change the post\'s vote count' do
          @post = Post.first
          expect(@post.yeses).to eq(1)
          expect(@post.nos).to eq(0)
          @agent.vote false, @post
          @post = Post.first
          expect(@post.yeses).to eq(1)
          expect(@post.nos).to eq(0)
        end
      end
    end

    context 'owns post' do
      before :each do
        @post = create(:post, approved: true, agent: @agent)
        @agent.posts.push(@post)
        @agent.save
        @agent.vote false, @post
      end

      it 'does not create another vote record' do
        expect(Vote.count).to eq(0)
      end
 
      it 'does not create another vote record for the agent' do
        @agent = Agent.first
        expect(@agent.votes.count).to eq(0)
      end
  
      it 'does not create another vote record for the post' do
        @post = Post.first
        expect(@post.votes.count).to eq(0)
      end
  
      it 'does not increment the post\'s vote count' do
        @post = Post.first
        expect(@post.yeses).to eq(0)
        expect(@post.nos).to eq(0)
      end
    end
  end

  describe '#tally_points' do
    before :each do
      @agent = create(:agent) 
    end

    it 'returns 0 if agent has no posts' do
      expect(@agent.posts.count).to eq(0)
      expect(@agent.tally_points).to eq(0)
    end

    it 'adds 10 for every approved post an agent has contributed' do
      post = create(:post, agent: @agent)
      expect(@agent.posts.count).to eq(1)
      expect(@agent.tally_points).to eq(0)

      post.approved = true
      post.save
      expect(@agent.tally_points).to eq(10)

      post = create(:another_post, agent: @agent, approved: true)
      expect(@agent.posts.count).to eq(2)
      expect(@agent.tally_points).to eq(20)
    end

    describe 'voting impact' do
      before :each do
        @post1 = create(:post, agent: @agent, approved: true)
        @post2 = create(:another_post, agent: @agent, approved: true)
        @another_agent = create(:another_agent) 
      end

      it 'adds 3 for every yes vote on an agent\'s post' do
        expect(@agent.tally_points).to eq(20)
        @another_agent.vote true, @post1
        expect(@agent.tally_points).to eq(23)
        @another_agent.vote true, @post2
        expect(@agent.tally_points).to eq(26)
      end

      it 'subtracts 1 for every no vote on an agent\'s post' do
        expect(@agent.tally_points).to eq(20)
        @another_agent.vote false, @post1
        expect(@agent.tally_points).to eq(19)
        @another_agent.vote false, @post2
        expect(@agent.tally_points).to eq(18)
      end

      it 'tallies all yeses and nos' do
        expect(@agent.tally_points).to eq(20)
        @another_agent.vote false, @post1
        expect(@agent.tally_points).to eq(19)
        @another_agent.vote true, @post2
        expect(@agent.tally_points).to eq(22)
      end
    end
  end
end
