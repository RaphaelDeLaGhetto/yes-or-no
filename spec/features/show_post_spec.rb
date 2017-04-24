require 'spec_helper'

describe "show post", :type => :feature do
  before :each do
    @agent = create(:agent)
    @post_1 = create(:post, agent: @agent, approved: true)
    @post_2 = create(:another_post, agent: @agent, approved: true)
    visit '/'
  end

  it 'displays a link to the posts' do
    expect(page).to have_selector("a[href='/post/#{@post_1.id}']", count: 1)
    expect(page).to have_selector("a[href='/post/#{@post_2.id}']", count: 1)
  end

  context 'not logged in' do
    it 'renders the post show page' do
      find("a[href='/post/#{@post_1.id}']").click
      expect(page).to have_current_path("/post/#{@post_1.id}")

      expect(page).to have_selector('.yes', count: 1)
      expect(page).to have_selector('.no', count: 1)
      expect(page).to have_selector('.star-ratings', count: 0)
      expect(page).to have_selector('.pending', count: 0)
      expect(page).to have_selector('.delete', count: 0)
      expect(page).to have_selector('header h1', :text => @post_1.tag)
    end
  end

  context 'owner agent logged in' do
    before :each do
      click_link 'Login'
      fill_in "email", :with => @agent.email 
      fill_in "password", :with => 'secret'
      click_button "Login"
      find("a[href='/post/#{@post_1.id}']").click
      expect(page).to have_current_path("/post/#{@post_1.id}")
    end

    it 'renders the post show page' do
      expect(page).to have_selector('.yes', count: 0)
      expect(page).to have_selector('.no', count: 0)
      expect(page).to have_selector('.star-ratings', count: 1)
      expect(page).to have_selector('.pending', count: 0)
      expect(page).to have_selector('.delete', count: 1)
      expect(page).to have_selector('header h1', :text => @post_1.tag)
    end
  end

  context 'non-owner agent logged in' do
    before :each do
      @another_agent = create(:another_agent)
      click_link 'Login'
      fill_in "email", :with => @another_agent.email 
      fill_in "password", :with => 'secret'
      click_button "Login"
      find("a[href='/post/#{@post_1.id}']").click
      expect(page).to have_current_path("/post/#{@post_1.id}")
    end

    it 'renders the post show page' do
      expect(page).to have_selector('.yes', count: 1)
      expect(page).to have_selector('.no', count: 1)
      expect(page).to have_selector('.star-ratings', count: 0)
      expect(page).to have_selector('.pending', count: 0)
      expect(page).to have_selector('.delete', count: 0)
      expect(page).to have_selector('header h1', :text => @post_1.tag)
    end
  end
end
