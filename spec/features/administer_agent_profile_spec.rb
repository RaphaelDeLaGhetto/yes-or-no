require 'spec_helper'

describe "administer agent profile", :type => :feature do

  #
  # 2017-4-29
  # These tests cover modifications made to the Padrino admin scaffold
  # templates. The default Padrino functionality is assumed to work for now
  #
  context 'admin logged in' do
    before :each do
      @agent = create(:agent)
      @another_agent = create(:another_agent)

      @post1 = create(:post, agent_id: @agent.id)
      @post2 = create(:another_post, agent_id: @agent.id)

      @admin = create(:admin)
      visit '/admin'
      fill_in "Email", :with => @admin.email
      fill_in "Password", :with => 'secret'
      click_button "Sign In"
      click_link "Agents"
    end

    it 'renders post count' do
      expect(page).to have_selector(".header", text: 'Posts')
      expect(page).to have_selector(".list-row:nth-of-type(1) .list-column:nth-of-type(6)", text: '2', count: 1)
      expect(page).to have_selector(".list-row:nth-of-type(2) .list-column:nth-of-type(6)", text: '0', count: 1)
    end

    it 'renders links to agent profile pages' do
      expect(page).to have_link("2", href: "/admin/agent/#{@agent.id}")
      expect(page).to have_link("0", href: "/admin/agent/#{@another_agent.id}")
    end

    describe 'agent trusted status', js: true do
      it 'toggles the agent trusted state to true if false' do
        @agent.trusted = false
        @agent.save 
        click_link "Agents"
        expect(Agent.find(@agent.id).trusted).to eq(false)
        find("#agent-#{@agent.id} .fa-square-o").click
        wait_for_ajax
        expect(Agent.find(@agent.id).trusted).to eq(true)
      end
   
      it 'toggles the agent trusted state to false if true' do
        expect(@agent.trusted).to eq(true)
        find("#agent-#{@agent.id} .fa-check-square-o").click
        wait_for_ajax
        expect(Agent.find(@agent.id).trusted).to eq(false)
      end
   
      it 'sets the unchecked box icon to checked' do
        @agent.trusted = false
        @agent.save 
        click_link "Agents"
        expect(Agent.find(@agent.id).trusted).to eq(false)
        expect(page).to have_selector("#agent-#{@agent.id} i.fa.fa-square-o")
        find("#agent-#{@agent.id} .fa-square-o").click
        wait_for_ajax
        expect(page).to have_selector("#agent-#{@agent.id} i.fa.fa-check-square-o")
      end
   
      it 'sets the checked box icon to unchecked' do
        expect(@agent.trusted).to eq(true)
        expect(page).to have_selector("#agent-#{@agent.id} i.fa.fa-check-square-o")
        find("#agent-#{@agent.id} .fa-check-square-o").click
        wait_for_ajax
        expect(page).to have_selector("#agent-#{@agent.id} i.fa.fa-square-o")
      end
    end

    describe 'edit agent' do
      before :each do
        find('.list-row:nth-of-type(2) .list-column.list-row-action .list-row-action-wrapper a:first').click
        expect(page).to have_current_path("/admin/agents/edit/#{@another_agent.id}")
      end

      it 'renders the password input in the edit form' do
        expect(page).to have_selector('input[name="agent[password]"]', count: 1)
      end

      describe 'password reset' do
        before :each do
          @old_hash = @another_agent.password_hash
          fill_in 'Password', :with => 'newpassword'
          click_button 'Save'
        end

        it 'updates the agent password in the database' do
          expect(Agent.find(@another_agent.id).password_hash).to_not eq(@old_hash)
        end

        it 'allows the agent to sign in with the new password' do
          visit '/login'
          fill_in "Email", :with => @another_agent.email 
          click_button 'Next'
          fill_in "Password", :with => 'newpassword'
          click_button "Login"
          expect(page).to have_current_path('/')
        end
      end

      describe 'trusted toggle' do
        before :each do
          expect(Agent.find(@another_agent.id).trusted).to be true
          uncheck 'trusted'
          click_button 'Save'
        end

        it 'updates the agent trusted column in the database' do
          expect(Agent.find(@another_agent.id).trusted).to be false
        end

        it 'toggles the trusted column back and forth' do
          expect(Agent.find(@another_agent.id).trusted).to be false
          check 'trusted'
          click_button 'Save'
          expect(Agent.find(@another_agent.id).trusted).to be true
          uncheck 'trusted'
          click_button 'Save'
          expect(Agent.find(@another_agent.id).trusted).to be false
        end
      end
    end

    describe 'show agent' do
      before :each do
        @post1.approved = true
        @post1.save
        click_link '2'
        expect(page).to have_current_path("/admin/agent/#{@agent.id}")
      end

      it "shows all posts belonging to the agent" do
        expect(@agent.posts.count).to eq(2)
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
    end
  end
end
