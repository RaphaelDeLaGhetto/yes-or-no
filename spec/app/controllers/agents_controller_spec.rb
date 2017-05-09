require 'spec_helper'

RSpec.describe "/agents" do
  describe 'POST /agents' do
    before :each do
      @agent = create(:agent)
    end

    context 'not authenticated' do
      it 'does not update agent record' do
        old_agent_url = @agent.url
        patch "/agents", { id: @agent.id, url: 'http://example.com' }
        expect(Agent.find(@agent.id).url).to eq(old_agent_url)
      end

      it "return 403 unauthorized" do
        patch "/agents", { id: @agent.id, url: 'http://example.com' }
        expect(last_response.status).to eq(403)
      end
    end

    context 'non-owner authenticated' do
      before :each do
        @another_agent = create(:another_agent)
      end

      it 'does not update agent record' do
        old_agent_url = @agent.url
        patch "/agents", { id: @agent.id, url: 'http://example.com' }, { 'rack.session' =>  { agent_id: @another_agent.id }}
        expect(Agent.find(@agent.id).url).to eq(old_agent_url)
      end

      it "return 403 unauthorized" do
        patch "/agents", { id: @agent.id, url: 'http://example.com' }, { 'rack.session' =>  { agent_id: @another_agent.id }}
        expect(last_response.status).to eq(403)
      end
    end
  end
end
