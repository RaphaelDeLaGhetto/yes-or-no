require 'spec_helper'

describe "landing page", :type => :feature do
  before :each do
    @agent = create(:agent)
    @post_1 = create(:post, agent: @agent, approved: true)
    @post_2 = create(:another_post, agent: @agent, approved: true)
    expect(@post_1.updated_at < @post_2.updated_at).to eq(true)
    @post_1.tag = 'lsb'
    @post_1.save
    expect(@post_1.updated_at > @post_2.updated_at).to eq(true)
    expect(@post_2.tag).not_to eq(@post_1.tag)
    visit '/'
  end

  context 'not logged in' do
    it 'renders page links' do
      expect(page).to have_link('Login', href: "/login")
      expect(page).to have_link('Top Picks', href: "/post")
      expect(page).to have_link('Yes or no?', href: "/about")
    end
  
    it 'renders recent posts yes/no buttons but no results' do
      expect(page).to have_selector('.yes', count: 2)
      expect(page).to have_selector('.no', count: 2)
      expect(page).to have_selector('.star-ratings', count: 0)
    end

    it "does not reveal vote tally or rank" do
      visit '/'
      expect(page).to have_selector('.nos', count: 0)
      expect(page).to have_selector('.yeses', count: 0)
      expect(page).to have_selector('.total-votes', count: 0)
      expect(page).to have_selector('.percent-rating', count: 0)
    end

    it 'renders posts in ascending order of updated_at' do
      expect(page).to have_selector("article:nth-of-type(1) header h1", :text => @post_2.tag)
      expect(page).to have_selector("article:nth-of-type(2) header h1", :text => @post_1.tag)
    end

    it 'puts new posts at the top of the list' do
      post = Post.create(url: 'http://example.com/new.jpg', tag: 'Brand new', approved: true, agent: @agent)
      expect(post.updated_at > @post_2.updated_at).to eq(true)
      visit '/'
      expect(page).to have_selector("article:nth-of-type(1) header h1", :text => post.tag)
      expect(page).to have_selector("article:nth-of-type(2) header h1", :text => @post_2.tag)
      expect(page).to have_selector("article:nth-of-type(3) header h1", :text => @post_1.tag)
    end

    describe 'get /post' do
      before :each do
        @post_2.nos = 100
        @post_2.yeses = 50  
        @post_2.save

        @post_1.nos = 50 
        @post_1.yeses = 100 
        @post_1.save

        expect(@post_1.rating > @post_2.rating).to eq(true)
  
        click_link 'Top Picks'
        expect(page).to have_current_path('/post')
      end

      it 'sets style for active link' do
        expect(page).to have_selector("a[href='/post'][class='active']", count: 1)
      end

      it 'renders post results but no yes/no buttons' do
        expect(page).to have_selector('.yes', count: 0)
        expect(page).to have_selector('.no', count: 0)
        expect(page).to have_selector('.star-ratings', count: 2)
      end

      it 'renders posts in descending order of rank' do
        expect(page).to have_selector("article:nth-of-type(1) header h1", :text => @post_1.tag)
        expect(page).to have_selector("article:nth-of-type(2) header h1", :text => @post_2.tag)
      end
    end


    describe 'get /about' do
      before :each do
        click_link 'Yes or no?'
      end 

      it "renders the 'about' page" do
        expect(page).to have_current_path('/about')
      end
    end
  end

  context 'owner agent logged in' do
    before :each do
      visit '/login'
      fill_in "Email", :with => @agent.email 
      fill_in "Password", :with => 'secret'
      click_button "Login"
    end

    it 'renders an account menu' do
      expect(page).to have_link('Top Picks', href: "/post")
      expect(page).to have_link('Your posts', href: "/agents/#{@agent.id}")
      expect(page).to have_link('Yeses', href: "/agents/#{@agent.id}/yeses")
      expect(page).to have_link('Nos', href: "/agents/#{@agent.id}/nos")
      expect(page).to have_link('Logout', href: '/logout')
    end

    it 'renders recent posts with results and no yes/no buttons' do
      expect(page).to have_selector('.yes', count: 0)
      expect(page).to have_selector('.no', count: 0)
      expect(page).to have_selector('.star-ratings', count: 2)
    end

    it 'renders posts in ascending order of updated_at' do
      expect(page).to have_selector("article:nth-of-type(1) header h1", :text => @post_2.tag)
      expect(page).to have_selector("article:nth-of-type(2) header h1", :text => @post_1.tag)
    end

    describe 'get /post' do
      before :each do
        @post_2.nos = 100
        @post_2.yeses = 50  
        @post_2.save

        @post_1.nos = 50 
        @post_1.yeses = 100 
        @post_1.save

        expect(@post_1.rating > @post_2.rating).to eq(true)
  
        click_link 'Top Picks'
        expect(page).to have_current_path('/post')
      end

      it 'sets style for active link' do
        expect(page).to have_selector("a[href='/post'][class='active']", count: 1)
      end

      it 'renders post results but no yes/no buttons' do
        expect(page).to have_selector('.yes', count: 0)
        expect(page).to have_selector('.no', count: 0)
        expect(page).to have_selector('.star-ratings', count: 2)
      end

      it 'renders posts in descending order of rank' do
        expect(page).to have_selector("article:nth-of-type(1) header h1", :text => @post_1.tag)
        expect(page).to have_selector("article:nth-of-type(2) header h1", :text => @post_2.tag)
      end
    end
  end

  context 'non-owner agent logged in' do
    before :each do
      @another_agent = create(:another_agent)
      visit '/login'
      fill_in "Email", :with => @another_agent.email 
      fill_in "Password", :with => 'secret'
      click_button "Login"
    end

    it 'renders an account menu' do
      expect(page).to have_link('Top Picks', href: "/post")
      expect(page).to have_link('Your posts', href: "/agents/#{@another_agent.id}")
      expect(page).to have_link('Yeses', href: "/agents/#{@another_agent.id}/yeses")
      expect(page).to have_link('Nos', href: "/agents/#{@another_agent.id}/nos")
      expect(page).to have_link('Logout', href: '/logout')
    end

    it 'renders recent posts with yes/no buttons and no results' do
      expect(page).to have_selector('.yes', count: 2)
      expect(page).to have_selector('.no', count: 2)
      expect(page).to have_selector('.star-ratings', count: 0)
    end

    it 'renders posts in ascending order of updated_at' do
      expect(page).to have_selector("article:nth-of-type(1) header h1", :text => @post_2.tag)
      expect(page).to have_selector("article:nth-of-type(2) header h1", :text => @post_1.tag)
    end

    describe 'get /post' do
      before :each do
        @post_2.nos = 100
        @post_2.yeses = 50  
        @post_2.save

        @post_1.nos = 50 
        @post_1.yeses = 100 
        @post_1.save

        expect(@post_1.rating > @post_2.rating).to eq(true)
  
        click_link 'Top Picks'
        expect(page).to have_current_path('/post')
      end

      it 'sets style for active link' do
        expect(page).to have_selector("a[href='/post'][class='active']", count: 1)
      end

      it 'renders post results but no yes/no buttons' do
        expect(page).to have_selector('.yes', count: 0)
        expect(page).to have_selector('.no', count: 0)
        expect(page).to have_selector('.star-ratings', count: 2)
      end

      it 'renders posts in descending order of rank' do
        expect(page).to have_selector("article:nth-of-type(1) header h1", :text => @post_1.tag)
        expect(page).to have_selector("article:nth-of-type(2) header h1", :text => @post_2.tag)
      end
    end
  end

end

