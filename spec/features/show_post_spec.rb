require 'spec_helper'

describe "show post", :type => :feature do
  before :each do
    @agent = create(:agent)
    @post_1 = create(:post, agent: @agent, approved: true)
    @post_2 = create(:another_post, agent: @agent, approved: true, tag: 'I like #pizza and #beer')
    visit '/'
  end

  it 'displays a link to the posts' do
    expect(page).to have_selector("a[href='/post/#{@post_1.id}']", count: 1)
    expect(page).to have_selector("a[href='/post/#{@post_2.id}']", count: 1)
  end

  it 'renders links to owner agent\'s profile by name, if set' do
    expect(page).to have_selector("a[href='/agents/#{@agent.id}']", text: @agent.name, count: 2)
    first(:link, @agent.name).click
    expect(page).to have_current_path("/agents/#{@agent.id}")
  end

  it 'renders links to owner agent\'s profile by Anonymous, if name not set' do
    @agent.name = '    '
    @agent.save
    visit '/'
    expect(page).to have_selector("a[href='/agents/#{@agent.id}']", text: 'Anonymous', count: 2)
    first(:link, 'Anonymous').click
    expect(page).to have_current_path("/agents/#{@agent.id}")
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
      expect(page).to have_selector('.owner', count: 1)
      expect(page).to have_selector('header h1', :text => @post_1.tag)
    end

    it 'creates links to hashtags' do
      find("a[href='/post/#{@post_2.id}']").click
      expect(page).to have_current_path("/post/#{@post_2.id}")
      expect(page).to have_content('I like')
      expect(page).to have_link("#pizza", href: "/post/search/pizza")
      expect(page).to have_content('and')
      expect(page).to have_link("#beer", href: "/post/search/beer")
    end

    it 'sets open graph meta data' do
      find("a[href='/post/#{@post_1.id}']").click
      expect(page).to have_current_path("/post/#{@post_1.id}")
      expect(page).to have_selector("meta[property='og:description'][content='#{@post_1.tag}']",
                                     count: 1, visible: false)
      expect(page).to have_selector("meta[property='og:title'][content='#{ENV['QUESTION']}']",
                                     count: 1, visible: false)
      expect(page).to have_selector("meta[property='og:type'][content='website']", count: 1, visible: false)
      expect(page).to have_selector("meta[property='og:url'][content='http://www.example.com/post/#{@post_1.id}']",
                                     count: 1, visible: false)
      expect(page).to have_selector("meta[property='og:image'][content='#{@post_1.url}']", count: 1, visible: false)
    end

    describe 'friendly forwarding', js: true do
      before :each do
        @post_3 = Post.create(url: 'http://example.com/crazy.jpg', agent: create(:another_agent), approved: true, tag: 'Too #crazy for me')
        proxy.stub(@post_3.url).and_return(redirect_to: "http://localhost:#{Capybara.current_session.server.port}/admin/images/logo.png")
        proxy.stub(@post_1.url).and_return(redirect_to: "http://localhost:#{Capybara.current_session.server.port}/admin/images/logo.png")
        proxy.stub(@post_2.url).and_return(redirect_to: "http://localhost:#{Capybara.current_session.server.port}/admin/images/logo.png")
        expect(@agent.votes.count).to eq(0)

        visit '/'
        find("a[href='/post/#{@post_3.id}']").click
 
        click_button 'No'
        wait_for_ajax

        fill_in "Email", :with => @agent.email 
        click_button "Next"
        fill_in "Password", :with => 'secret'
        click_button "Login"
      end

      it 'forwards to the clicked vote show page' do
        expect(page).to have_current_path("/post/#{@post_3.id}")
      end

      it 'renders the star rating' do
        expect(page).to have_selector('.star-ratings', count: 1)
      end

      it 'updates vote stuff' do
        expect(@post_3.votes.count).to eq(1)
        expect(@post_3.votes.last.yes).to eq(false)
        expect(@agent.votes.count).to eq(1)
        expect(@agent.votes.last.yes).to eq(false)
      end

      it 'renders a thank you message' do
        expect(page).to have_content('Thank you for your feedback')
      end

      context 'returning unauthenticated agent' do
        before :each do
          expect(@post_3.votes.count).to eq(1)
          expect(@agent.votes.count).to eq(1)
  
          click_link "Logout"
          visit '/'
          find("a[href='/post/#{@post_3.id}']").click
   
          click_button 'Yes'
          wait_for_ajax
  
          fill_in "Email", :with => @agent.email 
          click_button "Next"
          fill_in "Password", :with => 'secret'
          click_button "Login"
        end

        it 'forwards to the clicked vote show page' do
          expect(page).to have_current_path("/post/#{@post_3.id}")
        end
  
        it 'renders the star rating' do
          expect(page).to have_selector('.star-ratings', count: 1)
        end
  
        it 'does not change the vote stuff' do
          expect(@post_3.votes.count).to eq(1)
          expect(@post_3.votes.last.yes).to eq(false)
          expect(@agent.votes.count).to eq(1)
          expect(@agent.votes.last.yes).to eq(false)
        end
  
        it 'renders a voted already message' do
          expect(page).to have_content('Welcome back!')
        end
      end
    end
  end

  context 'owner agent logged in' do
    before :each do
      click_link 'Login'
      fill_in "email", :with => @agent.email 
      click_button 'Next'
      fill_in "password", :with => 'secret'
      click_button "Login"
      find("a[href='/post/#{@post_1.id}']").click
      expect(page).to have_current_path("/post/#{@post_1.id}")
    end

    it 'renders the post show page' do
      expect(page).to have_selector('.yes', count: 0)
      expect(page).to have_selector('.no', count: 0)
      expect(page).to have_selector('.star-ratings', count: 1)
      expect(page).to have_selector('.percent-rating', count: 1)
      expect(page).to have_selector('.pending', count: 0)
      expect(page).to have_selector('.delete', count: 1)
      expect(page).to have_selector('.owner', count: 1)
      expect(page).to have_selector('header h1', :text => @post_1.tag)
    end

    it 'does not render ranking details if there have been no responses' do
      expect(@post_1.votes.count).to eq(0)
      expect(@post_2.votes.count).to eq(0)
      expect(page).to have_selector('.nos', count: 0)
      expect(page).to have_selector('.yeses', count: 0)
      expect(page).to have_selector('.total-votes', count: 0)
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
      expect(page).to have_selector('.percent-rating', count: 1)
    end
  end

  context 'non-owner agent logged in', js: true do
    before :each do
      proxy.stub(@post_1.url).and_return(redirect_to: "http://localhost:#{Capybara.current_session.server.port}/admin/images/logo.png")
      proxy.stub(@post_2.url).and_return(redirect_to: "http://localhost:#{Capybara.current_session.server.port}/admin/images/logo.png")
 
      @another_agent = create(:another_agent)
      click_link 'Login'
      fill_in "email", :with => @another_agent.email 
      click_button 'Next'
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
      expect(page).to have_selector('.owner', count: 1)
      expect(page).to have_selector('header h1', :text => @post_1.tag)
    end

    it 'does not render ranking details if there have been no responses' do
      expect(@post_1.votes.count).to eq(0)
      expect(@post_2.votes.count).to eq(0)
      expect(page).to have_selector('.nos', count: 0)
      expect(page).to have_selector('.yeses', count: 0)
      expect(page).to have_selector('.total-votes', count: 0)
      expect(page).to have_selector('.percent-rating', count: 0)
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
        expect(page).to have_selector('.percent-rating', count: 1)
        post = Post.find(@post_1.id)
        expect(page).to have_content("#{post.rating}%")
        expect(page).to have_content("#{post.nos} + #{post.yeses} = #{post.nos + post.yeses}")
      end
    end
  end
end
