require 'spec_helper'

describe "infinite scroll", js: true, :type => :feature do

  #
  # 2017-5-5
  # Using `before :all` seems more efficient, but the puffing-billy
  # doesn't proxy correctly (or something)
  #
  before :each do
    @fake_agent = Agent.create(email: 'fake@email.com')
    (0..90).each do |num|
      post = Post.create(url: "http://fake.com/#{num}.jpg",
                  tag: "fake #{num}",
                  approved: true,
                  agent: @fake_agent)
      proxy.stub(post.url).
        and_return(redirect_to: "http://localhost:#{Capybara.current_session.server.port}/admin/images/logo.png")
    end 
    expect(Post.count).to eq(91)
  end

  it 'dummy' do
    # 2017-5-5
    # The hokiness persists
    #
    # 2017-4-17
    # For some reason, the database record is written but not accessible 
    # via the route. By putting this test here, everything seems to align.
    # Super hokey.
  end 

  context 'not logged in' do
    before :each do
      visit '/'
      wait_for_ajax
    end

    describe 'GET /' do
      it 'displays 30 posts initially' do
        expect(page).to have_selector('article', count: 30)
      end

      it "displays a 'Load more' link" do
        expect(page).to have_link('Load more...', href: '/?page=2')
      end

      describe 'manual page flipping' do
        it "allows the agent to load pages manually" do
          click_link 'Load more...'
          wait_for_ajax
          expect(page).to have_selector('article', count: 30)
          expect(page).to have_link('Load more...', href: '/?page=3')
          click_link 'Load more...'
          wait_for_ajax
          expect(page).to have_selector('article', count: 30)
          expect(page).to have_link('Load more...', href: '/?page=4')
          click_link 'Load more...'
          wait_for_ajax
          expect(page).to have_selector('article', count: 1)
          expect(page).to_not have_link('Load more...')
          expect(page).to have_content('Load more...')
          expect(page).to have_selector('.next_page.disabled', count: 1)
        end
      end
    end

    describe 'GET /post' do
      before :each do
        click_link 'Top Picks'
        wait_for_ajax
      end

      it 'displays 30 posts initially' do
        expect(page).to have_selector('article', count: 30)
      end

      it "displays a 'Load more' link" do
        expect(page).to have_link('Load more...', href: '/post?page=2')
      end

      describe 'manual page flipping' do
        it "allows the agent to load pages manually" do
          click_link 'Load more...'
          wait_for_ajax
          expect(page).to have_selector('article', count: 30)
          expect(page).to have_link('Load more...', href: '/post?page=3')
          click_link 'Load more...'
          wait_for_ajax
          expect(page).to have_selector('article', count: 30)
          expect(page).to have_link('Load more...', href: '/post?page=4')
          click_link 'Load more...'
          wait_for_ajax
          expect(page).to have_selector('article', count: 1)
          expect(page).to_not have_link('Load more...')
          expect(page).to have_content('Load more...')
          expect(page).to have_selector('.next_page.disabled', count: 1)
        end
      end
    end
  end

  context 'logged in' do
    before :each do
      @agent = create(:agent)
      visit '/login'
      fill_in "Email", :with => @agent.email 
      fill_in "Password", :with => 'secret'
      click_button "Login"
    end

    describe 'GET /' do
      before :each do
        visit '/'
        wait_for_ajax
      end

      it 'displays 30 posts initially' do
        expect(page).to have_selector('article', count: 30)
      end

      it "displays a 'Load more' link" do
        expect(page).to have_link('Load more...', href: '/?page=2')
      end

      describe 'manual page flipping' do
        it "allows the agent to load pages manually" do
          click_link 'Load more...'
          wait_for_ajax
          expect(page).to have_selector('article', count: 30)
          expect(page).to have_link('Load more...', href: '/?page=3')
          click_link 'Load more...'
          wait_for_ajax
          expect(page).to have_selector('article', count: 30)
          expect(page).to have_link('Load more...', href: '/?page=4')
          click_link 'Load more...'
          wait_for_ajax
          expect(page).to have_selector('article', count: 1)
          expect(page).to_not have_link('Load more...')
          expect(page).to have_content('Load more...')
          expect(page).to have_selector('.next_page.disabled', count: 1)
        end
      end
    end

    describe 'GET /post' do
      before :each do
        click_link 'Top Picks'
        wait_for_ajax
      end

      it 'displays 30 posts initially' do
        expect(page).to have_selector('article', count: 30)
      end

      it "displays a 'Load more' link" do
        expect(page).to have_link('Load more...', href: '/post?page=2')
      end

      describe 'manual page flipping' do
        it "allows the agent to load pages manually" do
          click_link 'Load more...'
          wait_for_ajax
          expect(page).to have_selector('article', count: 30)
          expect(page).to have_link('Load more...', href: '/post?page=3')
          click_link 'Load more...'
          wait_for_ajax
          expect(page).to have_selector('article', count: 30)
          expect(page).to have_link('Load more...', href: '/post?page=4')
          click_link 'Load more...'
          wait_for_ajax
          expect(page).to have_selector('article', count: 1)
          expect(page).to_not have_link('Load more...')
          expect(page).to have_content('Load more...')
          expect(page).to have_selector('.next_page.disabled', count: 1)
        end
      end
    end
  end
end
