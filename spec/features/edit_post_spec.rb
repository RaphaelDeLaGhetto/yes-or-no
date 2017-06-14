require 'spec_helper'

describe "edit post", :type => :feature do
  before :each do
    @agent = create(:agent)
    @post = create(:post, agent: @agent, approved: true)
  end

  context 'not logged in' do
    before :each do
      visit "/post/#{@post.id}"
    end

    it 'does not display an update button' do
      expect(false).to eq(true)
    end

    it 'sets the description field to not editable' do
      expect(false).to eq(true)
    end

    it 'does not allow an update' do
      expect(false).to eq(true)
    end

  end

  context 'non-owner agent logged in' do
    before :each do
      @another_agent = create(:another_agent) 
      visit '/login'
      fill_in 'Email', :with => @another_agent.email 
      click_button 'Next'
      fill_in 'Password', :with => 'secret' 
      click_button 'Login'
      visit "/post/#{@post.id}"
    end

    it 'does not display an update button' do
      expect(false).to eq(true)
    end

    it 'sets the description field to not editable' do
      expect(false).to eq(true)
    end

    it 'does not allow an update' do
      expect(false).to eq(true)
    end

  end

  context 'owner agent logged in' do
    before :each do
      visit '/login'
      fill_in "Email", :with => @agent.email 
      click_button "Next"
      fill_in "Password", :with => 'secret'
      click_button "Login"
      visit "/post/#{@post.id}"
    end


    it 'displays an update button' do
      expect(false).to eq(true)
    end

    it 'sets the description field to editable' do
      expect(false).to eq(true)
    end

    it 'allows an update' do
      expect(false).to eq(true)
    end

    it 'redirects to post after an update' do
      expect(false).to eq(true)
    end

    it 'does not allow a blank description' do
      expect(false).to eq(true)
    end
  end
end
