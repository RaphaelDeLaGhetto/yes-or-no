require 'spec_helper'

describe "de-approve images that are not found", js: true, :type => :feature do
  before :each do
    @agent = create(:agent)
    @post1 = Post.create(url: 'http://fakeurl.com/image.jpg',
                         tag: 'fake', approved: true,
                         agent: @agent)
    #
    # 2017-4-19
    # Notice the `image3.jpg`. `puffing-billy` doesn't seem to be resetting
    # stubs between tests. To recreate issue, set the pretend filename
    # to `image2.jpg` here and in the stub. This may also be due to cached
    # _images_.
    #
    @post2 = Post.create(url: 'http://fakeurl.com/image3.jpg',
                         tag: 'another fake', approved: true,
                         agent: @agent)
    expect(Post.count).to eq(2)

    proxy.stub('http://fakeurl.com/image.jpg').
      and_return(redirect_to: "http://localhost:#{Capybara.current_session.server.port}/admin/images/logo.png")
    proxy.stub('http://fakeurl.com/image3.jpg').and_return(code: 404)
  end

  context 'not logged in' do
    before :each do
      visit '/'
      wait_for_ajax
    end

    it 'dummy' do
      # 2017-4-19
      # For some reason, the database record is written but not accessible 
      # via the route. By putting this test here, everything seems to align.
      # Super hokey.
    end 

    it 'only displays images that successfully loaded' do
      expect(page).to have_selector('article', count: 1)
    end

    it 'de-approves the missing post' do
      expect(Post.find(@post1.id).approved).to eq(true)
      expect(Post.find(@post2.id).approved).to eq(false)
    end
  end

  context 'owner logged in' do
    before :each do
      visit '/login'
      fill_in "Email", :with => @agent.email 
      fill_in "Password", :with => 'secret'
      click_button "Login"
      wait_for_ajax
    end

    it 'only displays all posts' do
      expect(page).to have_selector('article', count: 2)
    end

    it 'displays an error message or the post that didn\'t load' do
      expect(page).to have_link("The image at #{@post2.url} could not be loaded", href: "/post/#{@post2.id}")
    end

    it 'de-approves the missing post' do
      expect(Post.find(@post1.id).approved).to eq(true)
      expect(Post.find(@post2.id).approved).to eq(false)
    end
  end

  context 'non-owner logged in' do
    before :each do
      @another_agent = create(:another_agent)
      visit '/login'
      fill_in "Email", :with => @another_agent.email 
      fill_in "Password", :with => 'secret'
      click_button "Login"
      wait_for_ajax
    end

    it 'only displays images that successfully loaded' do
      expect(page).to have_selector('article', count: 1)
    end

    it 'displays no error message for the post that didn\'t load' do
      expect(page).to_not have_link("The image at #{@post2.url} could not be loaded", href: "/post/#{@post2.id}")
    end

    it 'de-approves the missing post' do
      expect(Post.find(@post1.id).approved).to eq(true)
      expect(Post.find(@post2.id).approved).to eq(false)
    end
  end
end
