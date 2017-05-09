require 'spec_helper'

describe "agent account", :type => :feature do
  before :each do
    @agent = create(:agent)
    visit '/'
  end

  context 'not logged in' do
    it 'redirects to login' do
      visit "/agents/#{@agent.id}/posts"
      expect(page).to have_current_path('/login')
    end
  end

  context 'owner agent logged in' do
    before :each do
      visit '/login'
      fill_in "Email", :with => @agent.email 
      click_button "Next"
      fill_in "Password", :with => 'secret'
      click_button "Login"
    end

    it 'renders an account menu' do
      expect(page).to have_link('Your posts', href: "/agents/#{@agent.id}/posts")
      expect(page).to have_link('Yeses', href: "/agents/#{@agent.id}/yeses")
      expect(page).to have_link('Nos', href: "/agents/#{@agent.id}/nos")
      expect(page).to have_link('Logout', href: '/logout')
      expect(page).to have_link(@agent.points, href: "/agents/#{@agent.id}")
    end

    describe 'GET /agents/:id/posts' do
      before :each do
        @post = create(:post, agent: @agent)
        Post.create(url: 'http://fakeurl.com/image1.jpg', tag: 'fake', agent: Agent.create(email: 'fake@email.com'))
        expect(Post.count).to eq(2)
        click_link 'Your posts'
        expect(page).to have_current_path("/agents/#{@agent.id}/posts")
      end

      it 'sets style for active link' do
        expect(page).to have_selector("a[href='/agents/#{@agent.id}/posts'][class='active']", count: 1)
      end

      it 'only displays posts belonging to this agent' do
        expect(page).to have_selector('article', count: 1)
      end

      it 'does not display the yes/no buttons' do
        expect(page).to have_selector('.yes', count: 0)
        expect(page).to have_selector('.no', count: 0)
      end

      it 'display star rating' do
        expect(page).to have_selector('.star-ratings', count: 1)
        expect(page.find('.star-ratings').visible?).to eq(true)
      end

      it 'renders a submission form' do
        expect(page).to have_selector('input[name="url"]', count: 1)
        expect(page).to have_selector('input[name="tag"]', count: 1)
        expect(page).to have_selector('input[type="submit"]', count: 1)
      end
    end

    describe 'GET /agents/:id' do
      before :each do
        click_link "#{@agent.points}"
      end

      it 'renders total points' do
        expect(page).to have_content(@agent.points)
      end

      it 'displays email' do
        expect(page).to have_content(@agent.email)
      end

      it 'renders agent name if set' do
        expect(@agent.name).to_not be nil 
        expect(@agent.url).to be nil 
        expect(page).to have_content(@agent.name)
      end

      it 'renders Anonymous if name and url not set' do
        @agent.name = nil
        @agent.url = nil
        @agent.save
        @agent = Agent.find(@agent.id)
        expect(@agent.name).to be nil 
        expect(@agent.url).to be nil 
        click_link "#{@agent.points}"
        expect(page).to have_content('No name or homepage provided')
      end

      it 'renders Homepage as link if name not set but url is' do
        @agent.name = nil
        @agent.url = 'http://example.com'
        @agent.save
        @agent = Agent.find(@agent.id)
        click_link "#{@agent.points}"
        expect(page).to have_link('Homepage', :href => @agent.url)
      end

      it 'renders name as link if name and url are set' do
        @agent.name = 'My Company'
        @agent.url = 'http://example.com'
        @agent.save
        @agent = Agent.find(@agent.id)
        click_link "#{@agent.points}"
        expect(page).to have_link(@agent.name, :href => @agent.url)
      end

      it 'renders the edit form' do
        expect(page).to have_selector("input[name='name'][value='#{@agent.name}']", count: 1)
        expect(page.find("input[name='url']").text).to eq('')
        expect(page).to have_selector('input[type="submit"]', count: 1)
      end

      it 'renders the list of votes in descending order of creation' do
        @another_agent = create(:another_agent) 
        @post1 = create(:post, agent: @agent, approved: true)
        @post2 = create(:another_post, agent: @agent, approved: true)
        @another_agent.vote true, @post1
        @another_agent.vote false, @post2
        expect(Vote.count).to eq(2)
        expect(@post2.created_at).to be > @post1.created_at

        visit '/'
        click_link "#{@agent.points}"

        expect(page).to have_selector("article.vote", count: 2)
        expect(page).to have_selector("article:nth-of-type(2) span.change", :text => "-1")
        expect(page).to have_selector("article:nth-of-type(3) span.change", :text => "+3")
      end
  
      describe 'POST /agents' do
        context 'success' do
          before :each do
            fill_in 'Name', :with => 'Company Name Inc.'
            fill_in 'Homepage', :with => 'http://example.com'
            click_button 'Update'
          end
  
          it 'redirects to /agents/:id' do
            expect(page).to have_current_path("/agents/#{@agent.id}")
          end
    
          it 'updates the agent record' do
            agent = Agent.find(@agent.id)
            expect(agent.name).to eq('Company Name Inc.')
            expect(agent.url).to eq('http://example.com')
          end
  
          it 'renders the edit form' do
            agent = Agent.find(@agent.id)
            expect(page).to have_selector("input[name='name'][value='#{agent.name}']", count: 1)
            expect(page).to have_selector("input[name='url'][value='#{agent.url}']", count: 1)
            expect(page).to have_selector('input[type="submit"]', count: 1)
          end
  
          it 'renders a successful flash message' do
            expect(page).to have_content('Profile successfully updated')
          end
        end
  
        context 'failure' do
          before :each do
            fill_in 'Name', :with => 'Some Company Name'
            fill_in 'Homepage', :with => 'example.com'
            click_button 'Update'
          end
    
          it 'ends on /agents path' do
            expect(page).to have_current_path("/agents")
          end
   
          it 'renders the edit form' do
            expect(page).to have_selector('input[name="name"][value="Some Company Name"]', count: 1)
            expect(page).to have_selector('input[name="url"][value="example.com"]', count: 1)
            expect(page).to have_selector('input[type="submit"]', count: 1)
          end
    
          it 'does not update the agent record' do
            agent = Agent.find(@agent.id)
            expect(agent.name).to eq(@agent.name)
            expect(agent.url).to eq(@agent.url)
          end
  
          it 'renders a failure flash message' do
            expect(page).to have_content('Url is not a valid URL')
          end
        end
      end
    end

    describe 'GET /logout' do
      before :each do
        visit "/agents/#{@agent.id}/posts"
        expect(page).to have_current_path("/agents/#{@agent.id}/posts")
        expect(page).to have_link('Logout', :href => '/logout')
      end

      it 'clears the session' do
        click_link 'Logout'
        expect(page).to have_current_path('/')
        expect(page).to have_link('Login', :href => '/login')
        visit "/agents/#{@agent.id}/posts"
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

      it 'sets style for active link' do
        expect(page).to have_selector("a[href='/agents/#{@agent.id}/yeses'][class='active']", count: 1)
      end

      it 'only displays posts on which this agent voted yes' do
        expect(page).to have_selector('article', count: 1)
        expect(page).to have_selector('img[src="http://fakeurl.com/image2.jpg"]', count: 1)
      end

      it 'does not display the yes/no buttons' do
        expect(page).to have_selector('.yes', count: 0)
        expect(page).to have_selector('.no', count: 0)
      end

      it 'display star rating' do
        expect(page).to have_selector('.star-ratings', count: 1)
        expect(page.find('.star-ratings').visible?).to eq(true)
      end

      it 'does not render a submission form' do
        expect(page).to have_selector('input[name="url"]', count: 0)
        expect(page).to have_selector('input[name="tag"]', count: 0)
        expect(page).to have_selector('input[type="submit"]', count: 0)
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

      it 'sets style for active link' do
        expect(page).to have_selector("a[href='/agents/#{@agent.id}/nos'][class='active']", count: 1)
      end

      it 'only displays posts on which this agent voted no' do
        expect(page).to have_selector('article', count: 1)
        expect(page).to have_selector('img[src="http://fakeurl.com/image2.jpg"]', count: 1)
      end

      it 'does not display the yes/no buttons' do
        expect(page).to have_selector('.yes', count: 0)
        expect(page).to have_selector('.no', count: 0)
      end

      it 'display star rating' do
        expect(page).to have_selector('.star-ratings', count: 1)
        expect(page.find('.star-ratings').visible?).to eq(true)
      end

      it 'does not render a submission form' do
        expect(page).to have_selector('input[name="url"]', count: 0)
        expect(page).to have_selector('input[name="tag"]', count: 0)
        expect(page).to have_selector('input[type="submit"]', count: 0)
      end

    end

  end

  context 'non-owner agent logged in' do
    describe 'GET /agents/:id' do
      before :each do
        @another_agent = create(:another_agent) 
        visit '/login'
        fill_in 'Email', :with => @another_agent.email 
        click_button 'Next'
        fill_in 'Password', :with => 'secret' 
        click_button 'Login'
        visit "/agents/#{@agent.id}"
      end

      it 'lands on the right path' do
        expect(page).to have_current_path("/agents/#{@agent.id}")
      end
    
      it 'does not render the edit form' do
        expect(page).to have_selector("input[name='name']", count: 0)
        expect(page).to have_selector("input[name='url']", count: 0)
        expect(page).to have_selector('input[type="submit"]', count: 0)
      end

      it 'renders total points' do
        expect(page).to have_content(@agent.points)
      end

      it 'renders agent name if set' do
        expect(@agent.name).to_not be nil 
        expect(@agent.url).to be nil 
        expect(page).to have_content(@agent.name)
      end

      it 'renders Anonymous if name not set' do
        @agent.name = nil
        @agent.save
        @agent = Agent.find(@agent.id)
        expect(@agent.name).to be nil 
        visit "/agents/#{@agent.id}"
        expect(page).to have_content('No name or homepage provided')
      end

      it 'renders Homepage as link if name not set but url is' do
        @agent.name = nil
        @agent.url = 'http://example.com'
        @agent.save
        @agent = Agent.find(@agent.id)
        visit "/agents/#{@agent.id}"
        expect(page).to have_link('Homepage', :href => @agent.url)
      end

      it 'renders name as link if name and url are set' do
        @agent.name = 'My Company'
        @agent.url = 'http://example.com'
        @agent.save
        @agent = Agent.find(@agent.id)
        visit "/agents/#{@agent.id}"
        expect(page).to have_link(@agent.name, :href => @agent.url)
      end

      it 'does not display email' do
        expect(page).to_not have_content(@agent.email)
      end
    end
  end
end

