require 'spec_helper'

RSpec.describe "/" do
  describe 'POST /login/password' do
    before :each do
      @agent = create(:agent)
      create(:post, agent_id: @agent.id, approved: true)
      @agent = Agent.find(@agent.id)
      expect(@agent.points).to eq(10)
      expect(@agent.posts.count).to eq(1)
    end

    it 'calls tally_points on the agent on authentication' do
      @agent.points = 0
      @agent.save
      expect(Agent.find(@agent.id).points).to eq(0)
      post "/login/password", { email: @agent.email, password: 'secret' }
      expect(Agent.find(@agent.id).points).to eq(10)
    end
  end
end
