require 'spec_helper'

describe "agent login", :type => :feature do
  before :each do
    visit '/'
  end

  it 'renders a login link' do
    expect(page).to have_link('Login', :href => '/login')
  end

  describe 'login page' do
    before :each do
      click_link 'Login' 
    end

    it 'renders a sign up form' do
      expect(page).to have_selector('input[name="email"]', count: 1)
      expect(page).to have_selector('input[name="password"]', count: 1)
      expect(page).to have_selector('input[type="submit"]', count: 1)
    end

    describe 'success' do
      before :each do
        @agent = create(:agent) 
        fill_in "Email", :with => @agent.email
        fill_in "Password", :with => 'secret'
        click_button "Login" 
      end

      it 'redirect to home' do
        expect(page).to have_current_path('/')
      end

    end

    describe 'unknown agent failure' do
      before :each do
        fill_in "Email", :with => 'nosuchemail@example.com' 
        fill_in "Password", :with => 'secret'
        click_button "Login" 
      end

      it 'redirect to home' do
        expect(page).to have_current_path('/login')
      end

      it 'displays error message' do
        expect(page).to have_selector("input[name='email'][value='nosuchemail@example.com']", count: 1)
        expect(page).to have_content('Email or password incorrect')
      end
    end

    describe 'registered agent failure' do
      before :each do
        @agent = create(:agent) 
        fill_in "Email", :with => @agent.email 
        fill_in "Password", :with => 'wrong-password'
        click_button "Login" 
      end

      it 'redirect to home' do
        expect(page).to have_current_path('/login')
      end

      it 'displays error message' do
        expect(page).to have_selector("input[name='email'][value='#{@agent.email}']", count: 1)
        expect(page).to have_content('Email or password incorrect')
      end
    end
  end

end
