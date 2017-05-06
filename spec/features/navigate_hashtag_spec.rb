require 'spec_helper'

describe "navigate hashtag", :type => :feature do
  before :each do
    @agent = create(:agent)
    @post_1 = create(:post, agent: @agent, approved: true)
    @post_2 = create(:another_post, agent: @agent, approved: true, tag: 'I like #pizza and #beer')
  end

  context 'not logged in' do
    before :each do
      visit '/'
    end
  
    it 'creates links to hashtags' do
      expect(page).to have_selector('article', count: 2)
      expect(page).to have_link("#pizza", href: "/post/search/pizza")
      expect(page).to have_link("#beer", href: "/post/search/beer")
    end
  
    describe 'GET /post/search/pizza' do
      before :each do
        click_link '#pizza'
      end
  
      it 'lands on the correct path' do
        expect(page).to have_current_path('/post/search/pizza')
      end
  
      it 'renders matching posts' do
        expect(page).to have_selector('article', count: 1)
        expect(page).to have_selector("#post-#{@post_2.id}")
      end
    end
  end
end
