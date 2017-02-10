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
    expect(page).to have_current_path('/')
    expect(page).to have_content('Image submitted for review')

    expect(Post.count).to eq(1)
    expect(Post.first.approved).to be false
  end

end

