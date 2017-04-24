require 'spec_helper'

RSpec.describe "/post" do
  describe 'DELETE /post/:id' do
    before :each do
      @agent = create(:agent)
      @post_1 = create(:post, agent: @agent, approved: true)
      @post_2 = create(:another_post, agent: @agent, approved: true)
    end

    context 'not authenticated' do
      it 'does not remove the record from the database' do
        expect(Post.count).to eq(2)
        delete "/post/#{@post_1.id}"
        expect(Post.count).to eq(2)
      end

      it "return 403 unauthorized" do
        delete "/post/#{@post_1.id}"
        expect(last_response.status).to eq(403)
      end
    end

    context 'non-owner authenticated' do
      before :each do
        @another_agent = create(:another_agent)
      end

      it 'does not remove the record from the database' do
        expect(Post.count).to eq(2)
        delete "/post/#{@post_1.id}", {}, { 'rack.session' =>  { agent_id: @another_agent.id }}
        expect(Post.count).to eq(2)
      end

      it "return 403 unauthorized" do
        delete "/post/#{@post_1.id}", {}, { 'rack.session' =>  { agent_id: @another_agent.id }}
        expect(last_response.status).to eq(403)
      end
    end

    context 'owner authenticated' do
      it 'removes the record from the database' do
        expect(Post.count).to eq(2)
        delete "/post/#{@post_1.id}", {}, { 'rack.session' =>  { agent_id: @agent.id }}
        expect(Post.count).to eq(1)
      end

      it "redirects to agent page" do
        delete "/post/#{@post_1.id}", {}, { 'rack.session' =>  { agent_id: @agent.id }}
        expect(last_response.status).to eq(302)
        follow_redirect!
        expect(last_request.path).to eq("/agents/#{@agent.id}")
      end
    end
  end
end
