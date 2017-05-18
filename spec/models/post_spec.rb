require 'spec_helper'

RSpec.describe Post, type: :model do
  context 'database schema' do
    describe 'columns' do
      it { should have_db_column(:id) }
      it { should have_db_column(:url) }
      it { should have_db_column(:tag) }
      it { should have_db_column(:approved) }
      it { should have_db_column(:yeses) }
      it { should have_db_column(:nos) }
      it { should have_db_column(:created_at) }
      it { should have_db_column(:updated_at) }
    end
  end

  context 'validations' do
    subject { Post.new }
    it { should validate_presence_of(:url) }
    it { should validate_uniqueness_of(:url) }
    it { should validate_presence_of(:tag) }
    it { should validate_length_of(:tag).is_at_most(256).on(:create) }
    it { should_not allow_value('').for(:tag) }
    it { should_not allow_value('  ').for(:tag) }
    it { should_not allow_value('').for(:url) }
    it { should_not allow_value('  ').for(:url) }
  end

  context 'relationships' do
    subject { Post.new }
    it { should belong_to(:ip) }
    it { should belong_to(:agent) }
    it { should have_many(:votes) }

    describe 'deletion' do
      before :each do
        expect(Vote.count).to eq(0)
  
        @agent = create(:agent)
        @post = create(:post, agent: @agent, approved: true)
  
        agent2 = create(:another_agent)
        agent2.vote true, @post
      end

      it "deletes associated votes" do
        expect(Vote.count).to eq(1)
        @post.destroy
        expect(Vote.count).to eq(0)
      end
  
      it "re-tallies an agent's points" do
        expect(Agent.find(@agent.id).points).to eq(ENV['POST_POINTS'].to_i + ENV['YES_POINTS'].to_i)
        @post.destroy
        expect(Agent.find(@agent.id).points).to eq(0)
      end
    end

  end

  context 'initialization standard' do
    subject { Post.create({ url: 'http://example.com/pic.jpg', tag: 'Some example image' }) }
    it { expect(subject.yeses).to eq(0) }
    it { expect(subject.nos).to eq(0) }
    it { expect(subject.approved).to be(false) }
  end

  context 'initialization approved' do
    subject { Post.create({ url: 'http://example.com/pic.jpg',
                            tag: 'Some example image',
                            approved: true,
                            agent: create(:agent) }) }
    it { expect(subject.approved).to be(true) }
    it { expect(subject.agent.points).to eq(ENV['POST_POINTS'].to_i) }
  end


  context 'instance methods' do
    before :each do
      @post = create(:post)
    end

    describe '#answer_yes' do
      it 'returns an error if post is not approved' do
        expect(@post.approved).to be(false)
        expect(@post.yeses).to eq(0)
        @post.answer_yes
        expect(@post.errors.count).to eq(1)
        expect(@post.errors).to have_key(:approved)
        expect(@post.yeses).to eq(0)
        expect(Post.last.yeses).to eq(0)
      end

      it 'adds one to yeses if post is approved' do
        @post.approved = true
        @post.save
        expect(@post.approved).to be(true)
        expect(@post.yeses).to eq(0)
        @post.answer_yes
        expect(@post.errors.count).to eq(0)
        expect(@post.yeses).to eq(1)
        expect(Post.last.yeses).to eq(1)
      end
    end

    describe '#answer_no' do
      it 'returns an error if post is not approved' do
        expect(@post.approved).to be(false)
        expect(@post.nos).to eq(0)
        @post.answer_no
        expect(@post.errors.count).to eq(1)
        expect(@post.errors).to have_key(:approved)
        expect(@post.nos).to eq(0)
        expect(Post.last.nos).to eq(0)
      end

      it 'adds one to nos if post is approved' do
        @post.approved = true
        @post.save
        expect(@post.approved).to be(true)
        expect(@post.nos).to eq(0)
        @post.answer_no
        expect(@post.errors.count).to eq(0)
        expect(@post.nos).to eq(1)
        expect(Post.last.nos).to eq(1)
      end
    end

    describe '#rating' do
      it "doesn't barf if scores are 0" do
        expect(@post.yeses).to eq(0)
        expect(@post.nos).to eq(0)
        expect(@post.rating).to be(0)
      end

      it "returns an integer rank of 0 to 100" do
        # Yeses as percent of total are 83.33%
        # Integer division takes care of rounding
        @post.yeses = 10
        @post.nos = 2
        expect(@post.rating).to eq(((100 * 10) / (2 + 10)).round)
      end
    end
  end

  context 'class methods' do
    before :each do
      @post_0 = create(:post)
      @post_1 = Post.create(url: 'example.com/image_1.jpg', tag: 'Post 1', approved: true, yeses: 10, nos: 2)
      @post_2 = Post.create(url: 'example.com/image_2.jpg', tag: 'Post 2', approved: true)
      @post_3 = Post.create(url: 'example.com/image_3.jpg', tag: 'Post 3', approved: true, yeses: 100, nos: 10)
      expect(Post.count).to eq(4)
    end

    describe '.order_by_rating' do

      it "returns the posts in the order by which they're ranked" do
        posts = Post.order_by_rating
        expect(posts.length).to eq(3)
        expect(posts[0].id).to eq(@post_3.id)
        expect(posts[1].id).to eq(@post_1.id)
        expect(posts[2].id).to eq(@post_2.id)
      end
    end
  end

end
