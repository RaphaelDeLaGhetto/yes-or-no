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
        Post.create(url: 'fakeurl.com', tag: 'fake', agent: Agent.create(email: 'fake@emall.com'))
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
      end

    end

  end

end

