require 'spec_helper'

RSpec.describe Ip, type: :model do
  context 'database schema' do
    describe 'columns' do
      it { should have_db_column(:id) }
      it { should have_db_column(:address) }
      it { should have_db_column(:expired) }
      it { should have_db_column(:created_at) }
      it { should have_db_column(:updated_at) }
    end
  end

  context 'validations' do
    subject { Ip.new }
    it { should validate_presence_of(:address) }
  end

  context 'relationships' do
    subject { Ip.new }
    it { should have_many(:votes) }
    it { should have_and_belong_to_many(:agents) }
  end

end
