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
      expect(page).to have_selector('input[name="password"]', count: 0)
      expect(page).to have_selector('input[type="submit"]', count: 1)
    end
  end

  describe 'logging in' do
    before :each do
      @agent = create(:agent)
      click_link 'Login'
    end

    it 'redirects to home if successful' do
      fill_in "Email", :with => @agent.email 
      click_button "Next"
      fill_in "Password", :with => 'secret'
      click_button "Login"
      expect(page).to have_current_path('/')
    end

    it 'renders the password form if the password is wrong' do
      fill_in "Email", :with => @agent.email 
      click_button "Next"
      fill_in "Password", :with => 'wrongpassword'
      click_button "Login"
      expect(page).to have_current_path('/login/password')
      expect(page).to have_selector("input[name='password']", count: 1)
      expect(page).to have_content('Did you forget your password?')
    end

    it 'renders the login form if the email is invalid' do
      fill_in "Email", :with => 'example.com' 
      click_button "Next"
      expect(page).to have_current_path('/login')
      expect(page).to have_selector("input[name='email'][value='example.com']", count: 1)
      expect(page).to have_content('Email is invalid')
    end
  end

  context 'logged in' do
    before :each do
      @agent = create(:agent)
      click_link 'Login'
      fill_in "Email", :with => @agent.email 
      click_button "Next"
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
      expect(page).to have_link(ENV['QUESTION'], href: '/')
    end

  end

end

