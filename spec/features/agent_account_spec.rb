require 'spec_helper'

describe "agent account", :type => :feature do
  before :each do
    @agent = create(:agent)
    visit '/'
  end

  context 'not logged in' do
    it 'redirects to login' do
      visit "/agents/#{@agent.id}"
      expect(page).to have_current_path('/login')
    end
  end

  context 'logged in' do
    before :each do
      visit '/login'
      fill_in "Email", :with => @agent.email 
      fill_in "Password", :with => 'secret'
      click_button "Login"
    end

    it 'renders an account menu' do
      expect(page).to have_link('Your posts', href: "/agents/#{@agent.id}")
      expect(page).to have_link('Yeses', href: "/agents/#{@agent.id}/yeses")
      expect(page).to have_link('Nos', href: "/agents/#{@agent.id}/nos")
      expect(page).to have_link('Logout', href: '/logout')
    end

    describe 'GET /agents/:id' do
      before :each do
        @post = create(:post, agent: @agent)
        Post.create(url: 'http://fakeurl.com/image1.jpg', tag: 'fake', agent: Agent.create(email: 'fake@emall.com'))
        expect(Post.count).to eq(2)
        click_link 'Your posts'
        expect(page).to have_current_path("/agents/#{@agent.id}")
      end

      it 'only displays posts belonging to this agent' do
        expect(page).to have_selector('article', count: 1)
      end

      it 'does not display the yes/no buttons' do
        expect(page).to have_selector('.yes', count: 0)
        expect(page).to have_selector('.no', count: 0)
      end

      it 'display star rating' do
        expect(page).to have_selector('.star-ratings-css', count: 1)
        expect(page.find('.star-ratings-css').visible?).to eq(true)
      end

    end

    describe 'GET /logout' do
      before :each do
        visit "/agents/#{@agent.id}"
        expect(page).to have_current_path("/agents/#{@agent.id}")
        expect(page).to have_link('Logout', :href => '/logout')
      end

      it 'clears the session' do
        click_link 'Logout'
        expect(page).to have_current_path('/')
        expect(page).to have_link('Login', :href => '/login')
        visit "/agents/#{@agent.id}"
        expect(page).to have_current_path('/login')
      end
    end

    describe 'GET /agents/:id/yeses', js: true do
      before :each do
        proxy.stub('http://fakeurl.com/image1.jpg').and_return(redirect_to: "http://localhost:#{Capybara.current_session.server.port}/admin/images/logo.png")
        proxy.stub('http://fakeurl.com/image2.jpg').and_return(redirect_to: "http://localhost:#{Capybara.current_session.server.port}/admin/images/logo.png")

        @fake_agent = Agent.create(email: 'fake@emall.com')
        Post.create(url: 'http://fakeurl.com/image1.jpg', tag: 'fake 1', approved: true, agent: @fake_agent)
        Post.create(url: 'http://fakeurl.com/image2.jpg', tag: 'fake 2', approved: true, agent: @fake_agent)
        expect(Post.count).to eq(2)
        visit '/'
        wait_for_ajax
        click_button 'Yes', match: :first
        wait_for_ajax
        click_link ENV['QUESTION'] 
        click_link 'Yeses' 
      end

      it 'only displays posts on which this agent voted yes' do
        expect(page).to have_selector('article', count: 1)
        expect(page).to have_selector('img[src="http://fakeurl.com/image1.jpg"]', count: 1)
      end

      it 'does not display the yes/no buttons' do
        expect(page).to have_selector('.yes', count: 0)
        expect(page).to have_selector('.no', count: 0)
      end

      it 'display star rating' do
        expect(page).to have_selector('.star-ratings-css', count: 1)
        expect(page.find('.star-ratings-css').visible?).to eq(true)
      end
    end

    describe 'GET /agents/:id/nos', js: true do
      before :each do
        @fake_agent = Agent.create(email: 'fake@emall.com')
        Post.create(url: 'http://fakeurl.com/image1.jpg', tag: 'fake 1', approved: true, agent: @fake_agent)
        Post.create(url: 'http://fakeurl.com/image2.jpg', tag: 'fake 2', approved: true, agent: @fake_agent)
        expect(Post.count).to eq(2)
        visit '/'
        wait_for_ajax
        click_button 'No', match: :first
        wait_for_ajax
        click_link ENV['QUESTION'] 
        click_link 'Nos' 
      end

      it 'only displays posts on which this agent voted no' do
        expect(page).to have_selector('article', count: 1)
        expect(page).to have_selector('img[src="http://fakeurl.com/image1.jpg"]', count: 1)
      end

      it 'does not display the yes/no buttons' do
        expect(page).to have_selector('.yes', count: 0)
        expect(page).to have_selector('.no', count: 0)
      end

      it 'display star rating' do
        expect(page).to have_selector('.star-ratings-css', count: 1)
        expect(page.find('.star-ratings-css').visible?).to eq(true)
      end
    end

  end

end

