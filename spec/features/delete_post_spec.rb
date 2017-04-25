require 'spec_helper'

describe "delete post", :type => :feature do
  before :each do
    @agent = create(:agent)
    @post_1 = create(:post, agent: @agent, approved: true)
    @post_2 = create(:another_post, agent: @agent, approved: true)
    visit '/'
  end

  context 'not logged in' do
    it 'does not show the delete button' do
      find("a[href='/post/#{@post_1.id}']").click
      expect(page).to have_selector('.delete', count: 0)
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
    end
  
    it 'does not show the delete button' do
      find("a[href='/post/#{@post_1.id}']").click
      expect(page).to have_selector('.delete', count: 0)
    end
  end

  context 'owner agent logged in' do
    before :each do
      click_link 'Login'
      fill_in "email", :with => @agent.email 
      fill_in "password", :with => 'secret'
      click_button "Login"
      find("a[href='/post/#{@post_1.id}']").click
    end
  
    it 'removes the post from the database' do
      expect(Post.count).to eq(2)
      find("input.delete[type='submit']").click
      expect(Post.count).to eq(1)
    end

    it 'redirects to the agent\'s post page' do
      expect(page).to have_current_path("/post/#{@post_1.id}")
      find("input.delete[type='submit']").click
      expect(page).to have_current_path("/agents/#{@post_1.agent_id}")
    end

    it 'displays a confirmation message' do
      find("input.delete[type='submit']").click
      expect(page).to have_content("Post deleted")
    end
  end
end
