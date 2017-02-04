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
    it { should validate_presence_of(:url) }
    it { should validate_uniqueness_of(:url) }
    it { should validate_presence_of(:tag) }
    it { should validate_length_of(:tag).is_at_most(3).on(:create) }
  end

  context 'initialization' do
    before(:each) do
      @post = Post.create({ url: 'http://example.com/pic.jpg', tag: 'ldb' })
    end

    it 'sets yeses to 0' do
      expect(@post.yeses).to eq(0)
    end

    it 'sets nos to 0' do
      expect(@post.nos).to eq(0)
    end
  end

end
