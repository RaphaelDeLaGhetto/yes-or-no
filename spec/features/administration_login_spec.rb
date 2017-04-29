describe "administration login", :type => :feature do

  context 'not logged in' do
    before :each do
      visit '/admin'
      expect(page).to have_current_path('/admin/sessions/new')
      fill_in "Email", :with => "unknownagent@example.com"
      fill_in "Password", :with => 'password'
      click_button "Sign In"
    end

    it 'remains on the admin login page' do
      expect(page).to have_current_path('/admin/sessions/create')
    end

    it 're-renders the login form' do
      expect(page).to have_selector('input[name="email"][value="unknownagent@example.com"]', count: 1)
      expect(page).to have_selector('input[name="password"]', count: 1)
    end
  end

end
