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

    it 'does not render ranking details if there have been no responses' do
      expect(@post_1.votes.count).to eq(0)
      expect(@post_2.votes.count).to eq(0)
      expect(page).to have_selector('.nos', count: 0)
      expect(page).to have_selector('.yeses', count: 0)
      expect(page).to have_selector('.total-votes', count: 0)
      expect(page).to have_selector('.rating', count: 0)
      expect(page).to have_content('No one\'s answered')
    end

    it 'renders ranking details if there have been responses' do
      @post_1.answer_yes
      expect(@post_1.yeses).to eq(1) # votes.count will still be zero
      expect(@post_2.votes.count).to eq(0)
      visit("/post/#{@post_1.id}")
      expect(page).to have_selector('.nos', count: 1)
      expect(page).to have_selector('.yeses', count: 1)
      expect(page).to have_selector('.total-votes', count: 1)
      expect(page).to have_selector('.rating', count: 1)
    end
  end

  context 'non-owner agent logged in', js: true do
    before :each do
      proxy.stub(@post_1.url).and_return(redirect_to: "http://localhost:#{Capybara.current_session.server.port}/admin/images/logo.png")
      proxy.stub(@post_2.url).and_return(redirect_to: "http://localhost:#{Capybara.current_session.server.port}/admin/images/logo.png")
 
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

    it 'does not render ranking details if there have been no responses' do
      expect(@post_1.votes.count).to eq(0)
      expect(@post_2.votes.count).to eq(0)
      expect(page).to have_selector('.nos', count: 0)
      expect(page).to have_selector('.yeses', count: 0)
      expect(page).to have_selector('.total-votes', count: 0)
      expect(page).to have_selector('.rating', count: 0)
      expect(page).to_not have_content('No one\'s answered')
    end

    context 'there have been responses' do
      before :each do
        click_button 'Yes'
        wait_for_ajax
      end

      it 'renders ranking details if there have been responses' do
        expect(page).to have_selector('.nos', count: 1)
        expect(page).to have_selector('.yeses', count: 1)
        expect(page).to have_selector('.total-votes', count: 1)
        expect(page).to have_selector('.rating', count: 1)
        post = Post.find(@post_1.id)
        expect(page).to have_content("#{post.nos} + #{post.yeses} = #{post.nos + post.yeses} #{post.rating}%")
      end
    end
  end
end
