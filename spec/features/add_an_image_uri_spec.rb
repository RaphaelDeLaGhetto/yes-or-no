require 'spec_helper'

describe "add an image URI", :type => :feature do
  context 'not logged in' do
    before :each do
      visit '/agents/1/posts'
    end

    it 'redirects to login' do
      expect(page).to have_current_path('/login')
    end

    it 'does not render submission form' do
      expect(page).to have_selector('input[name="url"]', count: 0)
      expect(page).to have_selector('input[name="tag"]', count: 0)
    end
  end

  context 'admin logged in' do
    before :each do
      expect(ENV['AUTO_APPROVE'] == false || ENV['AUTO_APPROVE'] == nil).to be true
      @admin = create(:admin)
      @agent = create(:agent)
      visit '/login'
      fill_in "Email", :with => @agent.email
      click_button "Next"
      fill_in "Password", :with => 'secret'
      click_button "Login"
      click_link "Your posts"
    end

    it 'renders a submission form' do
      expect(page).to have_selector('input[name="url"]', count: 1)
      expect(page).to have_selector('input[name="tag"]', count: 1)
      expect(page).to have_selector('input[type="submit"]', count: 1)
    end
  
    describe 'unsuccessful image submission' do

      describe 'no image URL provided' do
        before :each do
          expect(Post.count).to eq(0)
          fill_in "url", :with => ""
          fill_in "tag", :with => "DSB"
          click_button "Add Image"
        end
  
        it "does not enter image into database" do
          expect(Post.count).to eq(0)
        end

        it "displays an error message" do
          expect(page).to have_content("Url can't be blank")
        end
      end

      describe 'no image description provided' do
        before :each do
          expect(Post.count).to eq(0)
          fill_in "url", :with => "http://example.com/image.jpg"
          fill_in "tag", :with => "  "
          click_button "Add Image"
        end
  
        it "does not enter image into database" do
          expect(Post.count).to eq(0)
        end

        it "displays an error message" do
          expect(page).to have_content("Tag can't be blank")
        end
      end
    end

    describe 'image submission' do
      before :each do
        expect(Post.count).to eq(0)
        fill_in "url", :with => "example.com/image.jpg"
        fill_in "tag", :with => "DSB"
        click_button "Add Image"
      end

      it "enters approved image into database" do
        expect(Post.count).to eq(1)
        post = Post.last
        expect(post.approved).to be true
      end

      it "displays a submission confirmation message" do
        expect(page).to_not have_content('Image submitted for review')
        expect(page).to have_content('Image submitted')
      end

      it "redirects to post show path" do
        expect(page).to have_current_path("/post/#{Post.first.id}")
      end
    
      it "displays the approved image in the agent's account" do
        visit "/agents/#{@agent.id}/posts"
        expect(page).to have_selector('article', count: 1)
        expect(page).to_not have_content('Pending approval')
        expect(page).to have_selector('.yes', count: 0)
        expect(page).to have_selector('.no', count: 0)
        expect(page).to have_css('.star-ratings') 
        expect(page).to have_selector('.star-ratings', count: 1)
      end
 
      it 'displays the pending post on the main page' do
        visit '/'
        expect(page).to have_selector('article', count: 1)
        expect(page).to_not have_content('Pending review')
      end
    end
  end

  context 'regular untrusted agent logged in' do
    before :each do
      expect(ENV['AUTO_APPROVE'] == false || ENV['AUTO_APPROVE'] == nil).to be true
      @another_agent = create(:another_agent, trusted: false)
      expect(@another_agent.trusted).to be false
      visit '/login'
      fill_in "Email", :with => @another_agent.email
      click_button "Next"
      fill_in "Password", :with => 'secret'
      click_button "Login"
      click_link "Your posts"
    end

    it 'renders a submission form' do
      expect(page).to have_selector('input[name="url"]', count: 1)
      expect(page).to have_selector('input[name="tag"]', count: 1)
      expect(page).to have_selector('input[type="submit"]', count: 1)
    end
  
    describe 'unsuccessful image submission' do

      describe 'no image URL provided' do
        before :each do
          expect(Post.count).to eq(0)
          fill_in "url", :with => ""
          fill_in "tag", :with => "DSB"
          click_button "Add Image"
        end
  
        it "does not enter image into database" do
          expect(Post.count).to eq(0)
        end

        it "displays an error message" do
          expect(page).to have_content("Url can't be blank")
        end
      end

      describe 'no image description provided' do
        before :each do
          expect(Post.count).to eq(0)
          fill_in "url", :with => "http://example.com/image.jpg"
          fill_in "tag", :with => "  "
          click_button "Add Image"
        end
  
        it "does not enter image into database" do
          expect(Post.count).to eq(0)
        end

        it "displays an error message" do
          expect(page).to have_content("Tag can't be blank")
        end
      end
    end

    describe 'image submission' do
      before :each do
        expect(Post.count).to eq(0)
        fill_in "url", :with => "example.com/image.jpg"
        fill_in "tag", :with => "DSB"
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
        visit "/agents/#{@another_agent.id}/posts"
        expect(page).to have_selector('article', count: 1)
        expect(page).to have_content('Pending approval')
        expect(page).to have_selector('.yes', count: 0)
        expect(page).to have_selector('.no', count: 0)
        expect(page).to have_css('.star-ratings') 
        expect(page).to have_selector('.star-ratings', count: 1)
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

    context 'image submission with ENV["AUTO_APPROVE"] == true' do
      before :each do
        @cached_auto_approve = ENV['AUTO_APPROVE']
        ENV['AUTO_APPROVE'] = 'true'
        expect(ENV['AUTO_APPROVE']).to eq 'true'
        expect(Post.count).to eq(0)
        fill_in "url", :with => "example.com/image.jpg"
        fill_in "tag", :with => "DSB"
        click_button "Add Image"
      end

      after :each do
        ENV['AUTO_APPROVE'] = @cached_auto_approve
      end

      it "enters an automatically approved image into database" do
        expect(Post.count).to eq(1)
        post = Post.last
        expect(post.approved).to be true
      end

      it "displays a submission confirmation message" do
        expect(page).to have_content('Image submitted successfully')
      end

      it "redirects to post show path" do
        expect(page).to have_current_path("/post/#{Post.first.id}")
      end
    
      it "displays the approved image in the agent's account" do
        visit "/agents/#{@another_agent.id}/posts"
        expect(page).to have_selector('article', count: 1)
        expect(page).to_not have_content('Image submitted for review')
        expect(page).to have_selector('.yes', count: 0)
        expect(page).to have_selector('.no', count: 0)
        expect(page).to have_css('.star-ratings') 
        expect(page).to have_selector('.star-ratings', count: 1)
      end
 
      it 'displays the post on the main page' do
        visit '/'
        expect(page).to have_selector('article', count: 1)
      end
    end
  end

  context 'regular trusted agent logged in' do
    before :each do
      expect(ENV['AUTO_APPROVE'] == false || ENV['AUTO_APPROVE'] == nil).to be true
      @another_agent = create(:another_agent)
      expect(@another_agent.trusted).to be true
      visit '/login'
      fill_in "Email", :with => @another_agent.email
      click_button "Next"
      fill_in "Password", :with => 'secret'
      click_button "Login"
      click_link "Your posts"
    end

    it 'renders a submission form' do
      expect(page).to have_selector('input[name="url"]', count: 1)
      expect(page).to have_selector('input[name="tag"]', count: 1)
      expect(page).to have_selector('input[type="submit"]', count: 1)
    end
  
    describe 'unsuccessful image submission' do

      describe 'no image URL provided' do
        before :each do
          expect(Post.count).to eq(0)
          fill_in "url", :with => ""
          fill_in "tag", :with => "DSB"
          click_button "Add Image"
        end
  
        it "does not enter image into database" do
          expect(Post.count).to eq(0)
        end

        it "displays an error message" do
          expect(page).to have_content("Url can't be blank")
        end
      end

      describe 'no image description provided' do
        before :each do
          expect(Post.count).to eq(0)
          fill_in "url", :with => "http://example.com/image.jpg"
          fill_in "tag", :with => "  "
          click_button "Add Image"
        end
  
        it "does not enter image into database" do
          expect(Post.count).to eq(0)
        end

        it "displays an error message" do
          expect(page).to have_content("Tag can't be blank")
        end
      end
    end

    describe 'image submission' do
      before :each do
        expect(Post.count).to eq(0)
        fill_in "url", :with => "example.com/image.jpg"
        fill_in "tag", :with => "DSB"
        click_button "Add Image"
      end

      it "enters an automatically approved image into database" do
        expect(Post.count).to eq(1)
        post = Post.last
        expect(post.approved).to be true
      end

      it "displays a submission confirmation message" do
        expect(page).to have_content('Image submitted successfully')
      end

      it "redirects to post show path" do
        expect(page).to have_current_path("/post/#{Post.first.id}")
      end
    
      it "displays the approved image in the agent's account" do
        visit "/agents/#{@another_agent.id}/posts"
        expect(page).to have_selector('article', count: 1)
        expect(page).to_not have_content('Image submitted for review')
        expect(page).to have_selector('.yes', count: 0)
        expect(page).to have_selector('.no', count: 0)
        expect(page).to have_css('.star-ratings') 
        expect(page).to have_selector('.star-ratings', count: 1)
      end
 
      it 'displays the post on the main page' do
        visit '/'
        expect(page).to have_selector('article', count: 1)
      end
    end
  end
end

