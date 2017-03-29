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
    it { should validate_length_of(:tag).is_at_most(50).on(:create) }
  end

  context 'initialization' do
    subject { Post.create({ url: 'http://example.com/pic.jpg', tag: 'Some example image' }) }
    it { expect(subject.yeses).to eq(0) }
    it { expect(subject.nos).to eq(0) }
    it { expect(subject.approved).to be(false) }
  end

  context 'instance methods' do
    describe '#answer_yes' do
      before :each do
        @post = create(:post)
      end

      it 'returns an error if post is not approved' do
        expect(@post.approved).to be(false)
        expect(@post.yeses).to eq(0)
        @post.answer_yes
        puts @post.errors.inspect
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

  end

end
