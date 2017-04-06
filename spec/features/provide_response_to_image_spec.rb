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
    wait_for_ajax
    expect(Post.last.yeses).to eq(1)
  end

  it "adds one to the yeses column in the database when No is pressed" do
    expect(@post.nos).to eq(0)
    visit '/'
    expect(page).to have_selector('article', count: 1)
    click_button 'No'
    wait_for_ajax
    expect(Post.last.nos).to eq(1)
  end

  it "reveals ranking when Yes is pressed" do
    visit '/'
    expect(page).to have_selector('.star-ratings-css', count: 0)
    click_button 'Yes'
    wait_for_ajax
    expect(page).to have_current_path("/")
    expect(page).to have_selector('.star-ratings-css', count: 1)
  end

  it "reveals ranking when No is pressed" do
    visit '/'
    expect(page).to have_selector('.star-ratings-css', count: 0)
    click_button 'No'
    wait_for_ajax
    expect(page).to have_current_path("/")
    expect(page).to have_selector('.star-ratings-css', count: 1)
  end

  it "sets the star rating when Yes is pressed" do
    visit '/'
    expect(page.find("article#post-#{@post.id} footer .star-ratings-css .star-ratings-css-top", visible: false)['style']).to eq(nil);
    click_button 'Yes'
    wait_for_ajax
    expect(page.find("article#post-#{@post.id} footer .star-ratings-css .star-ratings-css-top", visible: false)['style']).to eq("width: #{Post.last.rating}%; ");
  end

  it "sets the star rating when No is pressed" do
    visit '/'
    expect(page.find("article#post-#{@post.id} footer .star-ratings-css .star-ratings-css-top", visible: false)['style']).to eq(nil);
    click_button 'No'
    wait_for_ajax
    expect(page.find("article#post-#{@post.id} footer .star-ratings-css .star-ratings-css-top", visible: false)['style']).to eq("width: #{Post.last.rating}%; ");
  end

  it "disables the buttons when Yes is pressed" do
    visit '/'
    expect(page).to have_button('Yes', disabled: false, visible: true)
    expect(page).to have_button('No', disabled: false, visible: true)
    click_button 'Yes'
    wait_for_ajax
    expect(page).to have_button('Yes', disabled: true, visible: false)
    expect(page).to have_button('No', disabled: true, visible: false)
  end

  it "disables the buttons when No is pressed" do
    visit '/'
    expect(page).to have_button('Yes', disabled: false, visible: true)
    expect(page).to have_button('No', disabled: false, visible: true)
    click_button 'No'
    wait_for_ajax
    expect(page).to have_button('No', disabled: true, visible: false)
    expect(page).to have_button('Yes', disabled: true, visible: false)
  end

end
