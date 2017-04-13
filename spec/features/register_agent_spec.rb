require 'spec_helper'

describe "agent registration", :type => :feature do
  before :each do
    visit '/agents/new'
  end

  it 'renders a sign up form' do
    expect(page).to have_selector('input[name="agent[email]"]', count: 1)
    expect(page).to have_selector('input[name="agent[password]"]', count: 0)
    expect(page).to have_selector('input[type="submit"]', count: 1)
  end

  describe 'success' do
    before :each do
      SecureRandom.should_receive(:hex).and_return('abc123')
      expect(Agent.count).to eq(0)
      fill_in "Email", :with => "someguy@example.com"
      click_button "Register" 
    end

    it 'displays a message confirming email was sent' do
      expect(page).to have_content('Check your email to set your password')
    end

    it 'sends confirmation email' do
      email = Mail::TestMailer.deliveries.last
      expect(email.to).to eq(['someguy@example.com'])
      expect(email.from).to eq([ENV['EMAIL']])
      expect(email.subject).to have_content("Set your password to verify your account")
      expect(email.body).to have_content("#{ENV['HOST']}/confirm/abc123")
      expect(email.attachments.count).to eq(0)
    end

    it 'redirects to home after successful registration' do
      expect(page).to have_current_path('/')
    end

    it 'adds an agent to the database' do
      expect(Agent.count).to eq(1)
    end
  end

  describe 'failure' do
    before :each do
      @agent = create(:agent)
      visit '/agents/new'
    end

    it 'does not add a duplicate email to the database' do
      expect(Agent.count).to eq(1)
      fill_in "Email", :with => @agent.email 
      click_button "Register" 
      expect(Agent.count).to eq(1)
      expect(page).to have_current_path('/agents/create')
    end

#    it 'does not add a blank password to the database' do
#      expect(Agent.count).to eq(1)
#      fill_in "Email", :with => 'newagent@example.com' 
##      fill_in "agent_password", :with => ""
##      fill_in "agent_password_confirmation", :with => "secret"
#      click_button "Register" 
#      expect(Agent.count).to eq(1)
#      expect(page).to have_current_path('/agents/create')
#    end
  end

end
