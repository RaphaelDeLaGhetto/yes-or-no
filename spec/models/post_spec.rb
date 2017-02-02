require 'spec_helper'

RSpec.describe Post, type: :model do
  context 'database schema' do
    subject { Post }
    describe 'columns' do
      it { should have_db_column(:id) }
      it { should have_db_column(:url) }
#      it { should have_property(:initials) }
#      it { should have_property(:approved) }
#      it { should have_property(:yeses) }
#      it { should have_property(:nos) }
#      it { should have_property(:created_at) }
#      it { should have_property(:updated_at) }
    end
  end

  context 'validations' do
    subject { Post }
    it { should validate_presence_of (:url) }
    it { should validate_uniqueness_of (:url) }
#    it { should validate_presence_of(:description) }
#    it { should have_many(:performances) }
  end

  context 'troubleshooting' do
    it 'creates a new Post object' do
      expect(Post.new).to_not eq(nil) 
    end

    it 'saves a new Post object' do
      post = Post.new(url: 'http://taxreformyyc.com')
      puts post.save
      puts post.errors.messages
      expect(post.save).to eq(true)
      expect(Post.count).to eq(1) 
    end


  end


end
