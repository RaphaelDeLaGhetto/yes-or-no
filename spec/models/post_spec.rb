require 'spec_helper'

RSpec.describe Post, type: :model do
  context 'database schema' do
#    subject { Post }
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
#    subject { Post }
    it { should validate_presence_of (:url) }
    it { should validate_uniqueness_of (:url) }
#    it { should validate_presence_of(:description) }
#    it { should have_many(:performances) }
  end


end
