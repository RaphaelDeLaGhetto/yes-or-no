require 'spec_helper'

describe "provide a response to image", js: true, :type => :feature do
  before :each do
    @post = create(:post, approved: true)
  end

  it "adds one to the yeses column in the database when Yes is pressed" do
    expect(@post.yeses).to eq(0)
    visit '/'
    expect(page).to have_selector('article', count: 1)
    click_button 'Yes'
    expect(page).to have_current_path("/")
    expect(Post.last.yeses).to eq(1)
  end

  it "adds one to the yeses column in the database when No is pressed" do
    expect(@post.nos).to eq(0)
    visit '/'
    expect(page).to have_selector('article', count: 1)
    click_button 'No'
    expect(page).to have_current_path("/")
    expect(Post.last.nos).to eq(1)
  end



#  context 'approve an image URI' do
#    before :each do
#      @post = create(:post)
#      @admin = create(:admin)
#      visit '/'
#      expect(page).to have_selector('article', count: 0)
#    end
#
#    it 'displays the post on the main page' do
#      visit '/admin'
#      fill_in 'Email', :with => @admin.email
#      fill_in 'Password', :with => 'secret'
#      click_button 'Sign In'
#      expect(page).to have_current_path('/admin/')
#      click_link 'Posts'
#      expect(page).to have_current_path("/admin/posts")
#      expect(page).to have_selector('tr.list-row', count: 1)
#      click_link 'Edit post'
#      expect(page).to have_current_path("/admin/posts/edit/#{@post.id}")
#      check 'Approved:'
#      click_button 'Save and continue'
#      expect(page).to have_current_path("/admin/posts")
#      visit '/'
#      expect(page).to have_selector('article', count: 1)
#    end
#  end

end

