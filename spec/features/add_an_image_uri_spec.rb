require 'spec_helper'

describe "add an image URI", :type => :feature do
  before :each do
    visit '/'
  end

  context 'not logged in' do
    it 'does not render submission form' do
      expect(page).to have_selector('input[name="url"]', count: 0)
      expect(page).to have_selector('input[name="tag"]', count: 0)
      expect(page).to have_selector('input[type="submit"]', count: 0)
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
  
    describe 'image submission' do
      before :each do
        expect(Post.count).to eq(0)
        fill_in "Image URL", :with => "example.com/image.jpg"
        fill_in "Tag", :with => "DSB"
        click_button "Add Image"
      end

      it "enters unapproved image into database" do
        expect(Post.count).to eq(1)
        post = Post.last
        expect(post.approved).to be false
      end

      it "displays a submission confirmation message" do
        expect(page).to have_content('Image submitted for review')
      end

      it "redirects to post show path" do
        expect(page).to have_current_path("/post/#{Post.first.id}")
      end
    
      it "displays the unapproved image in the agent's account" do
        visit "/agents/#{@agent.id}"
        expect(page).to have_selector('article', count: 1)
        expect(page).to have_content('Pending approval')
        expect(page).to have_selector('.yes', count: 0)
        expect(page).to have_selector('.no', count: 0)
      end
 
      context 'approve an image URI' do
        before :each do
          @post = Post.first
          @admin = create(:admin)
          visit '/'
          expect(page).to have_selector('article', count: 0)
        end
    
        it 'displays the post on the main page' do
          visit '/admin/'
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
  end
end

