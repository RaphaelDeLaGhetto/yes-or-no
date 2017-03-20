require 'spec_helper'

RSpec.describe Post, type: :model do
  context 'database schema' do
    subject { Post.new }
    describe 'columns' do
      it { should have_db_column(:id) }
      it { should have_db_column(:url) }
      it { should have_db_column(:initials) }
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
#    it { should validate_presence_of(:description) }
#    it { should have_many(:performances) }
  end

  context 'initialization' do
    before do
      @post = Post.new
    end

    it 'sets yeses and nos to zero' do
      expect(@post.yeses).to eq(0)
      expect(@post.nos).to eq(0)
    end

    it 'is not approved' do
      expect(@post.approved).to be(false)
    end

  end

  context 'troubleshooting' do
    it 'creates a new Post object' do
      expect(Post.new).to_not eq(nil) 
    end

    it 'saves a new Post object' do
      post = Post.new(url: 'http://taxreformyyc.com')
      expect(post.save).to eq(true)
      expect(Post.count).to eq(1) 
    end


  end


end
