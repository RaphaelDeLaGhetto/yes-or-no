require 'spec_helper'

describe "authenticate agent", :type => :feature do
  before :each do
    visit '/'
  end

  context 'not logged in' do
    it 'displays a login link' do
      expect(page).to have_link('Login', href: '/login')
    end

    it 'leads to a login form' do
      click_link 'Login'
      expect(page).to have_selector('input[name="email"]', count: 1)
      expect(page).to have_selector('input[name="password"]', count: 1)
      expect(page).to have_selector('input[type="submit"]', count: 1)
      expect(page).to have_link('Signup or reset password', :href => '/agents/new')
    end
  end

  describe 'logging in' do
    before :each do
      @agent = create(:agent)
      click_link 'Login'
    end

    it 'redirects to home if successful' do
      fill_in "Email", :with => @agent.email 
      fill_in "Password", :with => 'secret'
      click_button "Login"
      expect(page).to have_current_path('/')
    end

    it 'renders the login form if the password is wrong' do
      fill_in "Email", :with => @agent.email 
      fill_in "Password", :with => 'wrongpassword'
      click_button "Login"
      expect(page).to have_current_path('/login')
      expect(page).to have_selector("input[name='email'][value='#{@agent.email}']", count: 1)
    end

    it 'renders the login form if the email is wrong' do
      fill_in "Email", :with => 'nosuchemail@example.com' 
      fill_in "Password", :with => 'secret'
      click_button "Login"
      expect(page).to have_current_path('/login')
      expect(page).to have_selector("input[name='email'][value='nosuchemail@example.com']", count: 1)
    end
  end

  context 'logged in' do
    before :each do
      @agent = create(:agent)
      click_link 'Login'
      fill_in "Email", :with => @agent.email 
      fill_in "Password", :with => 'secret'
      click_button "Login"
    end
  
    it "redirects to the homepage if visiting /login" do
      visit '/login'
      expect(page).to have_current_path('/')
    end

    it "redirects to the homepage if visiting /agents/new" do
      visit '/agents/new'
      expect(page).to have_current_path('/')
    end

    it "displays a link to the agent's account" do
      expect(page).to have_link('Account', href: "#")
    end

  end

end

