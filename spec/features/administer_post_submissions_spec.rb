require 'spec_helper'

describe "administer post submissions", :type => :feature do

  #
  # 2017-4-29
  # These tests cover modifications made to the Padrino admin scaffold
  # templates. The default Padrino functionality is assumed to work for now
  #
  context 'admin logged in', js: true do
    before :each do
      proxy.stub('http://example.com/image.jpg').
        and_return(redirect_to: "http://localhost:#{Capybara.current_session.server.port}/admin/images/logo.png")
      proxy.stub('http://example.com/another_image.jpg').
        and_return(redirect_to: "http://localhost:#{Capybara.current_session.server.port}/admin/images/logo.png")

      @agent = create(:agent)
      @post1 = create(:post, agent_id: @agent.id, approved: true)
      @post2 = create(:another_post, agent_id: @agent.id)

      @admin = create(:admin)
      visit '/admin'
      fill_in "Email", :with => @admin.email
      fill_in "Password", :with => 'secret'
      click_button "Sign In"
      click_link "Posts"
    end

    it 'renders the post images and approval icons' do
      expect(Post.count).to eq(2)
      expect(page).to have_selector("img[src='#{@post1.url}']", count: 1)
      expect(page).to have_selector("img[src='#{@post2.url}']", count: 1)
      expect(page).to have_selector('.list-column .fa-check-square-o', count: 1)
      expect(page).to have_selector('.list-column .fa-square-o', count: 1)
    end

    it 'renders unapproved posts first' do
      expect(@post1.approved).to eq(true)
      expect(@post2.approved).to eq(false)
      expect(page).to have_selector(".list-row:nth-of-type(1) .list-column:nth-of-type(2)", :text => @post2.id)
      expect(page).to have_selector(".list-row:nth-of-type(2) .list-column:nth-of-type(2)", :text => @post1.id)
    end

    it 'toggles the post approved state to true if false' do
      expect(@post2.approved).to eq(false)
      find(".list-column .fa-square-o").click
      wait_for_ajax
      expect(Post.find(@post2.id).approved).to eq(true)
    end

    it 'toggles the post approved state to false if true' do
      expect(@post1.approved).to eq(true)
      find(".list-column .fa-check-square-o").click
      wait_for_ajax
      expect(Post.find(@post1.id).approved).to eq(false)
    end

    it 'sets the unchecked box icon to checked' do
      expect(@post2.approved).to eq(false)
      expect(page).to have_selector("#post-#{@post2.id} i.fa.fa-square-o")
      find(".list-column .fa-square-o").click
      wait_for_ajax
      expect(page).to have_selector("#post-#{@post2.id} i.fa.fa-check-square-o")
    end

    it 'sets the checked box icon to unchecked' do
      expect(@post1.approved).to eq(true)
      expect(page).to have_selector("#post-#{@post1.id} i.fa.fa-check-square-o")
      find(".list-column .fa-check-square-o").click
      wait_for_ajax
      expect(page).to have_selector("#post-#{@post1.id} i.fa.fa-square-o")
    end

  end
end

