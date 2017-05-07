require 'spec_helper'


describe "provide a response to image", js: true, :type => :feature do
  before :each do
    @post = Post.create(url: 'http://fakeurl.com/image.jpg', tag: 'fake', approved: true, agent: Agent.create(email: 'fake@emall.com'))
    proxy.stub('http://fakeurl.com/image.jpg').and_return(redirect_to: "http://localhost:#{Capybara.current_session.server.port}/admin/images/logo.png")
    expect(Post.count).to eq(1)
  end

  context 'not logged in' do
    before :each do
      visit '/'
    end

    it 'dummy' do
      # 2017-4-17
      # For some reason, the database record is written but not accessible 
      # via the route. By putting this test here, everything seems to align.
      # Super hokey.
    end 

    it 'redirects to login' do
      click_button 'Yes'
      wait_for_ajax
      expect(page).to have_current_path('/login')
    end

    it 'does not change vote count' do
      expect(Post.first.yeses).to eq(0)
      click_button 'Yes'
      wait_for_ajax
      expect(Post.first.yeses).to eq(0)
    end

    it "does not add a yes vote" do
      expect(Vote.count).to eq(0)
      click_button 'Yes'
      wait_for_ajax
      expect(Vote.count).to eq(0)
    end
  end

  context 'logged in' do
    before :each do
      @agent = create(:agent)
      visit '/login'
      fill_in "Email", :with => @agent.email 
      click_button 'Next'
      fill_in "Password", :with => 'secret'
      click_button "Login"
    end

    it "adds a yes vote to the agent" do
      expect(Vote.count).to eq(0)
      expect(Agent.last.votes.count).to eq(0)
      click_button 'Yes'
      wait_for_ajax
      expect(Vote.count).to eq(1)
      expect(Agent.last.votes.count).to eq(1)
      expect(Agent.last.votes[0].yes).to eq(true)
    end

    it "adds a yes vote to the post" do
      expect(Vote.count).to eq(0)
      expect(Post.first.votes.count).to eq(0)
      click_button 'Yes'
      wait_for_ajax
      expect(Vote.count).to eq(1)
      expect(Post.first.votes.count).to eq(1)
      expect(Post.first.votes[0].yes).to eq(true)
    end

    it "adds one to the yeses column in the database when Yes is pressed" do
      expect(@post.yeses).to eq(0)
      visit '/'
      expect(page).to have_selector('article', count: 1)
      click_button 'Yes'
      wait_for_ajax
      expect(Post.last.yeses).to eq(1)
    end
  
    it "adds one to the nos column in the database when No is pressed" do
      expect(@post.nos).to eq(0)
      visit '/'
      expect(page).to have_selector('article', count: 1)
      click_button 'No'
      wait_for_ajax
      expect(Post.last.nos).to eq(1)
    end
  
    it "adds a no vote to the agent" do
      expect(Vote.count).to eq(0)
      expect(Agent.last.votes.count).to eq(0)
      click_button 'No'
      wait_for_ajax
      expect(Vote.count).to eq(1)
      expect(Agent.last.votes.count).to eq(1)
      expect(Agent.last.votes[0].yes).to eq(false)
    end

    it "adds a no vote to the post" do
      expect(Vote.count).to eq(0)
      expect(Post.first.votes.count).to eq(0)
      click_button 'No'
      wait_for_ajax
      expect(Vote.count).to eq(1)
      expect(Post.first.votes.count).to eq(1)
      expect(Post.first.votes[0].yes).to eq(false)
    end

    it "reveals ranking when Yes is pressed" do
      visit '/'
      expect(page).to have_selector('.star-ratings', count: 0)
      click_button 'Yes'
      wait_for_ajax
      expect(page).to have_current_path("/")
      expect(page).to have_selector('.star-ratings', count: 1)
    end
  
    it "reveals ranking when No is pressed" do
      visit '/'
      expect(page).to have_selector('.star-ratings', count: 0)
      click_button 'No'
      wait_for_ajax
      expect(page).to have_current_path("/")
      expect(page).to have_selector('.star-ratings', count: 1)
    end
  
    it "reveals vote tally and rank when Yes is pressed" do
      visit '/'
      expect(page).to have_selector('.nos', count: 0)
      expect(page).to have_selector('.yeses', count: 0)
      expect(page).to have_selector('.total-votes', count: 0)
      expect(page).to have_selector('.percent-rating', count: 0)
      click_button 'Yes'
      wait_for_ajax
      expect(page).to have_selector('.nos', count: 1)
      expect(page).to have_selector('.yeses', count: 1)
      expect(page).to have_selector('.total-votes', count: 1)
      expect(page).to have_selector('.percent-rating', count: 1)
      post = Post.last
      expect(page).to have_content("#{post.rating}%")
      expect(page).to have_content("#{post.nos} + #{post.yeses} = #{post.nos + post.yeses}")
    end

    it "reveals vote tally and rank when No is pressed" do
      visit '/'
      expect(page).to have_selector('.nos', count: 0)
      expect(page).to have_selector('.yeses', count: 0)
      expect(page).to have_selector('.total-votes', count: 0)
      expect(page).to have_selector('.percent-rating', count: 0)
      click_button 'No'
      wait_for_ajax
      expect(page).to have_selector('.nos', count: 1)
      expect(page).to have_selector('.yeses', count: 1)
      expect(page).to have_selector('.total-votes', count: 1)
      expect(page).to have_selector('.percent-rating', count: 1)
      post = Post.last
      expect(page).to have_content("#{post.rating}%")
      expect(page).to have_content("#{post.nos} + #{post.yeses} = #{post.nos + post.yeses}")
    end

    it "sets the star rating when Yes is pressed" do
      visit '/'
      expect(page.find("article#post-#{@post.id} footer .star-ratings .star-ratings-top", visible: false)['style']).to eq('width: 0%;');
      click_button 'Yes'
      wait_for_ajax
      expect(page.find("article#post-#{@post.id} footer .star-ratings .star-ratings-top", visible: false)['style']).to eq("width: #{Post.last.rating}%;");
    end
  
    it "sets the star rating when No is pressed" do
      visit '/'
      expect(page.find("article#post-#{@post.id} footer .star-ratings .star-ratings-top", visible: false)['style']).to eq('width: 0%;');
      click_button 'No'
      wait_for_ajax
      expect(page.find("article#post-#{@post.id} footer .star-ratings .star-ratings-top", visible: false)['style']).to eq("width: #{Post.last.rating}%;");
    end
  
    it "disables the buttons when Yes is pressed" do
      visit '/'
      expect(page).to have_button('Yes', disabled: false, visible: true)
      expect(page).to have_button('No', disabled: false, visible: true)
      click_button 'Yes'
      wait_for_ajax
      expect(page).to have_button('Yes', disabled: true, visible: false)
      expect(page).to have_button('No', disabled: true, visible: false)
    end
  
    it "disables the buttons when No is pressed" do
      visit '/'
      expect(page).to have_button('Yes', disabled: false, visible: true)
      expect(page).to have_button('No', disabled: false, visible: true)
      click_button 'No'
      wait_for_ajax
      expect(page).to have_button('No', disabled: true, visible: false)
      expect(page).to have_button('Yes', disabled: true, visible: false)
    end
  end
end
