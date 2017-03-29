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
        expect(@post.rating).to be(nil)
      end

      it "returns a rank of 0 to 4" do
        @post.yeses = 10
        @post.nos = 2
        expect(@post.rating).to eq((4 * 10) / (2 + 10))
        expect(@post.rating <= 4).to be(true)
      end
    end
  end

end
