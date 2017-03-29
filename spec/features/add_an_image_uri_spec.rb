require 'spec_helper'

describe "add an image URI", :type => :feature do
  before :each do
#    @agent = create(:client_agent)
#    page.set_rack_session(agent_id: @agent.id)
  end

  it "submits an image for review" do
    expect(Post.count).to eq(0)

    visit '/'
    fill_in "Image URL", :with => "example.com/image.jpg"
    fill_in "Tag", :with => "DSB"
    click_button "Add Image"

    expect(Post.count).to eq(1)
    post = Post.last
    expect(post.approved).to be false
    expect(page).to have_current_path("/post/#{post.id}")
    expect(page).to have_content('Image submitted for review')
  end

  context 'approve an image URI' do
    before :each do
      @post = create(:post)
      @admin = create(:admin)
      visit '/'
      expect(page).to have_selector('article', count: 0)
    end

    it 'displays the post on the main page' do
      visit '/admin'
      fill_in 'Email', :with => @admin.email
      fill_in 'Password', :with => 'secret'
      click_button 'Sign In'
      expect(page).to have_current_path('/admin/')
      click_link 'Posts'
      expect(page).to have_current_path("/admin/posts")
      expect(page).to have_selector('tr.list-row', count: 1)
      click_link 'Edit post'
      expect(page).to have_current_path("/admin/posts/edit/#{@post.id}")
      check 'Approved:'
      click_button 'Save and continue'
      expect(page).to have_current_path("/admin/posts")
      visit '/'
      expect(page).to have_selector('article', count: 1)
    end
  end

end

