require 'spec_helper'

describe "agent registration", :type => :feature do
  before :each do
    visit '/agents/new'
  end

  it 'renders a sign up form' do
    expect(page).to have_selector('input[name="agent[email]"]', count: 1)
    expect(page).to have_selector('input[name="agent[password]"]', count: 1)
    expect(page).to have_selector('input[type="submit"]', count: 1)
  end

  describe 'success' do
    before :each do
      expect(Agent.count).to eq(0)
      fill_in "Email", :with => "someguy@example.com"
      fill_in "agent_password", :with => "secret"
      fill_in "agent_password_confirmation", :with => "secret"
      click_button "Register" 
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
      fill_in "agent_password", :with => "secret"
      fill_in "agent_password_confirmation", :with => "secret"
      click_button "Register" 
      expect(Agent.count).to eq(1)
      expect(page).to have_current_path('/agents/create')
    end

    it 'does not add a blank password to the database' do
      expect(Agent.count).to eq(1)
      fill_in "Email", :with => 'newagent@example.com' 
      fill_in "agent_password", :with => ""
      fill_in "agent_password_confirmation", :with => "secret"
      click_button "Register" 
      expect(Agent.count).to eq(1)
      expect(page).to have_current_path('/agents/create')
    end
  end

end
