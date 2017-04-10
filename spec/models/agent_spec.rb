require 'spec_helper'

RSpec.describe Agent do

  context 'database schema', type: :model do
    describe 'columns' do
      it { should have_db_column(:id) }
      it { should have_db_column(:name) }
      it { should have_db_column(:email) }
      it { should have_db_column(:password) }
      it { should have_db_column(:created_at) }
      it { should have_db_column(:updated_at) }
    end
  end

  context 'validations' do
    subject { Agent.new }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:password) }
  end

  context 'relationships' do
    subject { Agent.new }
    it { should have_many(:votes) }
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
      @agent.password_confirmation = nil
    end

    it 'requires a password confirmation' do
      expect(@agent.password_confirmation).to be_nil
      expect(@agent.valid?).to be_falsey
      @agent.password_confirmation = 'secret'
      expect(@agent.valid?).to be_truthy
    end
  end
end
