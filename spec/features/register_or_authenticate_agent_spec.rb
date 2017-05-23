require 'spec_helper'

describe "agent registration or authentication", :type => :feature do
  before :each do
    Mail::TestMailer.deliveries.clear
    visit '/login'
  end

  it 'renders a sign-up/sign-in form' do
    expect(page).to have_selector('input[name="email"][autofocus="autofocus"]', count: 1)
    expect(page).to have_selector('input[name="password"]', count: 0)
    expect(page).to have_selector('input[type="submit"]', count: 1)
  end

  describe 'GET /login/password' do
    it 'redirects if no email provided' do
      visit '/login/password'
      expect(page).to have_current_path('/login')
    end
  end

  describe "registering an unknown agent", :type => :feature do
    describe 'failure' do

      describe 'mangled email' do
        before :each do
          fill_in "Email", :with => 'not_an_email.com' 
          click_button "Next"
        end
    
        it 'does not add a mangled email to the database' do
          expect(Agent.count).to eq(0)
        end
     
        it 'displays an error on the agent create page' do
          expect(page).to have_content('Email is invalid')
        end
    
        it 'does not send a confirmation or notification email' do
          expect(Mail::TestMailer.deliveries.count).to eq(0)
        end
    
        it 'remains on the login page' do
          expect(page).to have_current_path('/login')
        end
      end
  
      describe 'blank email' do
        before :each do
          Mail::TestMailer.deliveries.clear
          fill_in "Email", :with => '  ' 
          click_button "Next"
        end
   
        it 'does not add a record to the database' do
          expect(Agent.count).to eq(0)
        end
     
        it 'displays an error on the agent create page' do
          expect(page).to have_content("Email can't be blank")
        end
    
        it 'does not send a confirmation or notification email' do
          expect(Mail::TestMailer.deliveries.count).to eq(0)
        end
    
        it 'remains on the login page' do
          expect(page).to have_current_path('/login')
        end
      end
    end

    describe 'successful' do
      before :each do
        allow(SecureRandom).to receive(:hex).and_return('abc123')
        Mail::TestMailer.deliveries.clear
        expect(Agent.count).to eq(0)
        fill_in 'Email', :with => 'dan@example.com'
        click_button 'Next'
      end
  
      it 'creates a new agent record in the database' do
        expect(Agent.count).to eq(1)
        agent = Agent.first
        expect(agent.name).to eq(nil)
        expect(agent.email).to eq('dan@example.com')
        expect(agent.password_hash).to eq(nil)
        expect(agent.confirmation_hash).to_not eq(nil)
      end
  
      it 'redirects to the home page' do
        expect(page).to have_current_path('/')
        expect(page).to have_content('Welcome! Check your email')
      end

      it 'sends a confirmation email' do
        expect(Mail::TestMailer.deliveries.count).to eq(1)
        email = Mail::TestMailer.deliveries.last
        expect(email.to).to eq(['dan@example.com'])
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

      describe 'unverified agent return visit' do
        before :each do
          Mail::TestMailer.deliveries.clear
          click_link 'Logout'
          visit  '/'
          click_link 'Login'
          expect(Agent.count).to eq(1)
          fill_in 'Email', :with => 'dan@example.com'
          click_button 'Next'
        end

        it 'does not add a record to the database' do
          expect(Agent.count).to eq(1)
        end
     
        it 'does not send a confirmation or notification email' do
          expect(Mail::TestMailer.deliveries.count).to eq(0)
        end

        it 'renders password form' do
          expect(page).to have_selector('input[type="hidden"][name="email"]', visible: false, count: 1)
          expect(page).to have_selector('input[name="password"][autofocus="autofocus"]', count: 1)
          expect(page).to have_selector('input[type="submit"][value="Login"]', count: 1)
        end

        it 'redirects to the password page' do
          expect(page).to have_current_path('/login/password')
        end

        it 'does not accept a blank password' do
          fill_in 'Password', :with => '   '
          click_button 'Login'
          expect(page).to have_current_path('/login/password')
          expect(page).to have_content('Did you forget your password?')
        end

        it 'does not accept any password' do
          fill_in 'Password', :with => 'secret'
          click_button 'Login'
          expect(page).to have_current_path('/login/password')
          expect(page).to have_content('Did you forget your password?')
        end

        it 'renders a reset password form' do
          expect(page).to have_selector('input[type="hidden"][name="email"]', visible: false, count: 1)
          expect(page).to have_selector('input[type="submit"][value="Reset password"]', count: 1)
        end

        describe 'password reset/agent verification' do

          before :each do
            allow(SecureRandom).to receive(:hex).and_return('abc123')
            expect(Agent.count).to eq(1)
            click_button 'Reset password'
          end

          it 'displays a message confirming email was sent' do
            expect(page).to have_content('Check your email to set your password')
          end
      
          it 'sends confirmation email' do
            email = Mail::TestMailer.deliveries.last
            expect(email.to).to eq(['dan@example.com'])
            expect(email.from).to eq([ENV['EMAIL']])
            expect(email.subject).to have_content("Set your password to verify your account")
            expect(email.body).to have_content("#{ENV['HOST']}/agents/#{Agent.first.id}/confirm/abc123")
            expect(email.attachments.count).to eq(0)
          end
      
          it 'redirects to home after successful reset request' do
            expect(page).to have_current_path('/')
          end
      
          it 'does not add an agent to the database' do
            expect(Agent.count).to eq(1)
          end

          describe 'email password set' do
            context 'success' do
              before :each do
                visit "/agents/#{Agent.first.id}/confirm/abc123"
              end
        
              it 'renders a password form' do
                expect(page).to have_selector('input[name="agent[email]"]', count: 0)
                expect(page).to have_selector('input[name="agent[password]"][autofocus="autofocus"]', count: 1)
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

              describe 'verified agent return visit' do
                before :each do
                  fill_in "Password", :with => 'secret'
                  click_button "Update"
                  click_link "Logout"
                  Mail::TestMailer.deliveries.clear
                  click_link 'Login'
                  expect(Agent.count).to eq(1)
                  fill_in 'Email', :with => 'dan@example.com'
                  click_button 'Next'
                  fill_in 'Password', :with => 'secret'
                  click_button 'Login'
                end
  
                it 'redirects to home' do
                  expect(page).to have_current_path('/')
                end
  
                it 'does not add an email to the database' do
                  expect(Agent.count).to eq(1)
                end
             
                it 'does not send a confirmation or notification email' do
                  expect(Mail::TestMailer.deliveries.count).to eq(0)
                end
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
      end
    end
  end

  context 'registering an unknown agent with ENV["SIGNUP_NOTIFICATION"] == true' do
    before :each do
      @cached_auto_approve = ENV['SIGNUP_NOTIFICATION']
      ENV['SIGNUP_NOTIFICATION'] = 'true'
      expect(ENV['SIGNUP_NOTIFICATION']).to eq 'true'
      allow(SecureRandom).to receive(:hex).and_return('abc123')
      expect(Agent.count).to eq(0)
      fill_in "Email", :with => "someguy@example.com"
      click_button "Nex" 
    end

    after :each do
      ENV['SIGNUP_NOTIFICATION'] = @cached_auto_approve
    end

    it 'displays a message confirming email was sent' do
      expect(page).to have_content('Welcome! Check your email')
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
#      expect(email.from).to eq([ENV['EMAIL']])
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


end
