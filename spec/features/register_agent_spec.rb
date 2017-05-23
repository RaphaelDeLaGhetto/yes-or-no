require 'spec_helper'

describe "agent registration", :type => :feature do
  before :each do
    Mail::TestMailer.deliveries = []
    visit '/agents/new'
  end

  it 'renders a sign up form' do
    expect(page).to have_selector('input[name="agent[email]"]', count: 1)
    expect(page).to have_selector('input[name="agent[password]"]', count: 0)
    expect(page).to have_selector('input[type="submit"]', count: 1)
  end

  describe 'success' do
    before :each do
      allow(SecureRandom).to receive(:hex).and_return('abc123')
      expect(Agent.count).to eq(0)
      fill_in "Email", :with => "someguy@example.com"
      click_button "Send" 
    end

    it 'displays a message confirming email was sent' do
      expect(page).to have_content('Check your email to set your password')
    end

    it 'sends confirmation email' do
      email = Mail::TestMailer.deliveries.last
      expect(email.to).to eq(['someguy@example.com'])
      expect(email.from).to eq([ENV['EMAIL']])
      expect(email.subject).to have_content("Set your password to verify your account")
      expect(email.body).to have_content("#{ENV['HOST']}/agents/#{Agent.first.id}/confirm/abc123")
      expect(email.attachments.count).to eq(0)
    end


    it 'does not send a notification email to ENV["EMAIL"]' do
      expect(ENV['SIGNUP_NOTIFICATION'] == false || ENV['SIGNUP_NOTIFICATION'] == nil).to be true
      # Cf. test above
      expect(Mail::TestMailer.deliveries.count).to eq(1)
    end

    it 'redirects to home after successful registration' do
      expect(page).to have_current_path('/')
    end

    it 'adds an agent to the database' do
      expect(Agent.count).to eq(1)
    end

    describe 'email password set' do
      context 'success' do
        before :each do
          visit "/agents/#{Agent.first.id}/confirm/abc123"
        end
  
        it 'renders a password form' do
          expect(page).to have_selector('input[name="agent[email]"]', count: 0)
          expect(page).to have_selector('input[name="agent[password]"]', count: 1)
          expect(page).to have_selector('input[type="submit"]', count: 1)
        end
    
        it 'does not allow a blank password' do
          fill_in "Password", :with => ''
          click_button "Update"
          expect(page).to have_current_path('/agents/confirm')
          expect(page).to have_content('Password cannot be blank')
          fill_in "Password", :with => '    '
          click_button "Update"
          expect(page).to have_current_path('/agents/confirm')
          expect(page).to have_content('Password cannot be blank')
        end
  
        it 'sets confirmation_hash to nil in the database' do
          fill_in "Password", :with => 'secret'
          click_button "Update"
          expect(Agent.first.confirmation_hash).to be_nil 
        end

        it 'redirects home if successful and logs in' do
          fill_in "Password", :with => 'secret'
          click_button "Update"
          expect(page).to have_current_path('/')
          expect(page).to have_link('Logout', href: '/logout')
        end
      end

      context 'failure' do
        it 'returns 404 if agent does not exist' do
          visit "/agents/333/confirm/abc123"
          expect(page.status_code).to eq(404)
        end

        it 'renders error message if confirmation code is wrong' do
          visit "/agents/#{Agent.first.id}/confirm/nosuchcode"
          expect(page).to have_current_path('/agents/new')
          expect(page).to have_content('That code is either invalid or expired. Enter email to reset password or signup.')
        end
      end
    end
  end

  context 'success with ENV["SIGNUP_NOTIFICATION"] == true' do
    before :each do
      @cached_auto_approve = ENV['SIGNUP_NOTIFICATION']
      ENV['SIGNUP_NOTIFICATION'] = 'true'
      expect(ENV['SIGNUP_NOTIFICATION']).to eq 'true'
      allow(SecureRandom).to receive(:hex).and_return('abc123')
      expect(Agent.count).to eq(0)
      fill_in "Email", :with => "someguy@example.com"
      click_button "Send" 
    end

    after :each do
      ENV['SIGNUP_NOTIFICATION'] = @cached_auto_approve
    end

    it 'displays a message confirming email was sent' do
      expect(page).to have_content('Check your email to set your password')
    end

    it 'sends confirmation email' do
      expect(Mail::TestMailer.deliveries.count).to eq(2)
      email = Mail::TestMailer.deliveries[0]
      expect(email.to).to eq(['someguy@example.com'])
      expect(email.from).to eq([ENV['EMAIL']])
      expect(email.subject).to have_content("Set your password to verify your account")
      expect(email.body).to have_content("#{ENV['HOST']}/agents/#{Agent.first.id}/confirm/abc123")
      expect(email.attachments.count).to eq(0)
    end

    it 'sends notification email to ENV["EMAIL"]' do
      email = Mail::TestMailer.deliveries[1]
      expect(email.to).to eq([ENV['EMAIL']])
      expect(email.from).to eq(['someguy@example.com'])
      expect(email.subject).to have_content("Email signup: someguy@example.com")
      expect(email.body).to have_content("#{ENV['HOST']}/agents/#{Agent.first.id}")
      expect(email.attachments.count).to eq(0)
    end

    it 'redirects to home after successful registration' do
      expect(page).to have_current_path('/')
    end

    it 'adds an agent to the database' do
      expect(Agent.count).to eq(1)
    end
  end

  describe 'existing agent' do
    before :each do
      @agent = create(:agent)
      expect(Agent.count).to eq(1)
      Mail::TestMailer.deliveries.clear
      visit '/agents/new'
      fill_in "Email", :with => @agent.email 
      click_button "Send"
    end

    it 'does not add a duplicate email to the database' do
      expect(Agent.count).to eq(1)
    end

    it 'redirects to the home page' do
      expect(page).to have_current_path('/')
    end

    it 'sends a confirmation email' do
      expect(Mail::TestMailer.deliveries.count).to eq(1)
    end

    it 'displays a message confirming email was sent' do
      expect(page).to have_content('Check your email to set your password')
    end
  end

  describe 'mangled email' do
    before :each do
      Mail::TestMailer.deliveries.clear
      visit '/agents/new'
      fill_in "Email", :with => 'not_an_email.com' 
      click_button "Send"
    end

    it 'does not add a mangled email to the database' do
      expect(Agent.count).to eq(0)
    end
 
    it 'displays an error on the agent create page' do
      expect(page).to have_content('The email is invalid')
    end

    it 'does not send a confimration email' do
      expect(Mail::TestMailer.deliveries.count).to eq(0)
    end

    it 'remains on the registration page' do
      expect(page).to have_current_path('/agents/create')
    end
  end
end
