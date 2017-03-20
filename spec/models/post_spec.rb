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
    it { should validate_length_of(:tag).is_at_most(3).on(:create) }
 
  end

  context 'initialization' do
    subject { Post.create({ url: 'http://example.com/pic.jpg', tag: 'ldb' }) }
    it { expect(subject.yeses).to eq(0) }
    it { expect(subject.nos).to eq(0) }
    it { expect(subject.approved).to be(false) }
  end

end
