require 'spec_helper'

RSpec.describe "/api" do
  describe 'POST /post' do
    before :each do
      @agent = create(:agent)
    end

    describe 'authentication' do
      it 'returns 403 for an unregistered agent' do 
        post "/api/auth", { email: 'someguy@example.com', password: 'secret' }.to_json
        expect(last_response.status).to eq(403)
        expect(last_response.body).to eq('')
      end

      it 'returns a JWT token' do 
        post "/api/auth", { email: @agent.email, password: 'secret' }.to_json
        expect(last_response.status).to eq(200)
        expect(last_response.body).to_not eq(nil)
        decoded_token = JWT.decode(JSON.parse(last_response.body)['token'],
                                   ENV['HMAC_SECRET'], false, { :algorithm => 'HS256' })
        expect(decoded_token[0]['agent_id']).to eq(@agent.id)
      end
    end

    context 'not authenticated' do
      it 'does not allow agent to create a new post' do
        expect(Post.count).to eq(0)
        post "/api/post", { id: @agent.id, url: 'http://example.com/mypic.jpg', tag: 'My pic. Enjoy...' }.to_json
        expect(Post.count).to eq(0)
      end

      it "return 403 unauthorized and message" do
        post "/api/post", { id: @agent.id, url: 'http://example.com/mypic.jpg', tag: 'My pic. Enjoy...' }.to_json
        expect(last_response.status).to eq(403)
        expect(JSON.parse(last_response.body)['error']).to eq('Invalid token')
      end
    end

#    context 'authenticated' do
#      before :each do 
#        post "/api/auth", { email: @agent.email, password: 'secret' }
#      end
#
#      it "return 200" do
#        post "/api/post", { token: @token, url: 'http://example.com/mypic.jpg', tag: 'My pic. Enjoy...' }
#        expect(last_response.status).to eq(200)
#      end
#
#      it 'allows agent to create a new post' do
#        expect(Post.count).to eq(0)
#        post "/api/post", { token: @token, url: 'http://example.com/mypic.jpg', tag: 'My pic. Enjoy...' }
#        expect(Post.count).to eq(1)
#        post = Post.first
#        expect(post.agent_id).to eq(@agent.id)
#      end
#
#    end

    context 'admin logged in' do
      before :each do
        expect(ENV['AUTO_APPROVE'] == false || ENV['AUTO_APPROVE'] == nil).to be true
        @admin = create(:admin)
        post "/api/auth", { email: @admin.email, password: 'secret' }.to_json
        expect(last_response.status).to eq(200)
        @token = JSON.parse(last_response.body)['token'] 
      end
  
      it "returns 200" do
        post "/api/post", { token: @token, url: 'http://example.com/mypic.jpg', tag: 'My pic. Enjoy...' }.to_json
        expect(last_response.status).to eq(200)
      end

      describe 'unsuccessful image submission' do
        describe 'no image URL provided' do
          before :each do
            expect(Post.count).to eq(0)
            post "/api/post", { token: @token, tag: 'My pic. Enjoy...' }.to_json
          end
    
          it "does not enter image into database" do
            expect(Post.count).to eq(0)
          end
  
          it "returns 400 with error message" do
            expect(last_response.status).to eq(400)
            expect(JSON.parse(last_response.body)['error']).to eq("Url can't be blank")
          end
        end

        describe 'no image tag provided' do
          before :each do
            expect(Post.count).to eq(0)
            post "/api/post", { token: @token, url: 'http://example.com/mypic.jpg' }.to_json
          end
    
          it "does not enter image into database" do
            expect(Post.count).to eq(0)
          end

          it "returns 400 with error message" do
            expect(last_response.status).to eq(400)
            expect(JSON.parse(last_response.body)['error']).to eq("Tag can't be blank")
          end 
        end
      end

      describe 'image submission' do
        before :each do
          expect(Post.count).to eq(0)
          post "/api/post", { token: @token, url: 'http://example.com/mypic.jpg', tag: 'My pic. Enjoy...' }.to_json
        end
  
        it "enters approved image into database" do
          expect(Post.count).to eq(1)
          post = Post.last
          expect(post.approved).to be true
        end
  
        it "returns 200 with success message" do
          expect(last_response.status).to eq(200)
          expect(JSON.parse(last_response.body)['message']).to eq("Image submitted successfully")
        end 

        it "creates the record in the database" do
          expect(Post.count).to eq(1)
          post = Post.last
          expect(post.approved).to be true
          # Remember, Account vs. Agent models
          expect(post.agent).to eq(@agent)
          expect(post.url).to eq('http://example.com/mypic.jpg')
          expect(post.tag).to eq('My pic. Enjoy...')
        end
      end
    end
  end

  context 'regular untrusted agent logged in' do
    before :each do
      expect(ENV['AUTO_APPROVE'] == false || ENV['AUTO_APPROVE'] == nil).to be true
      @another_agent = create(:another_agent, trusted: false)
      expect(@another_agent.trusted).to be false

      post "/api/auth", { email: @another_agent.email, password: 'secret' }.to_json
      expect(last_response.status).to eq(200)
      @token = JSON.parse(last_response.body)['token'] 
    end

    describe 'unsuccessful image submission' do
      describe 'no image URL provided' do
        before :each do
          expect(Post.count).to eq(0)
          post "/api/post", { token: @token, tag: 'My pic. Enjoy...' }.to_json
        end
  
        it "does not enter image into database" do
          expect(Post.count).to eq(0)
        end

        it "returns 400 with error message" do
          expect(last_response.status).to eq(400)
          expect(JSON.parse(last_response.body)['error']).to eq("Url can't be blank")
        end
      end

      describe 'no image tag provided' do
        before :each do
          expect(Post.count).to eq(0)
          post "/api/post", { token: @token, url: 'http://example.com/mypic.jpg' }.to_json
        end
    
        it "does not enter image into database" do
          expect(Post.count).to eq(0)
        end

        it "returns 400 with error message" do
          expect(last_response.status).to eq(400)
          expect(JSON.parse(last_response.body)['error']).to eq("Tag can't be blank")
        end 
      end
    end

    describe 'image submission' do
      before :each do
        expect(Post.count).to eq(0)
        post "/api/post", { token: @token, url: 'http://example.com/mypic.jpg', tag: 'My pic. Enjoy...' }.to_json
      end

      it "enters unapproved image into database" do
        expect(Post.count).to eq(1)
        post = Post.last
        expect(post.approved).to be false
      end

      it "returns 200 with success message" do
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['message']).to eq("Image submitted for review")
      end

      it "creates the record in the database" do
        expect(Post.count).to eq(1)
        post = Post.last
        expect(post.approved).to be false
        expect(post.agent).to eq(@another_agent)
        expect(post.url).to eq('http://example.com/mypic.jpg')
        expect(post.tag).to eq('My pic. Enjoy...')
      end
    end

    context 'image submission with ENV["AUTO_APPROVE"] == true' do
      before :each do
        @cached_auto_approve = ENV['AUTO_APPROVE']
        ENV['AUTO_APPROVE'] = 'true'
        expect(ENV['AUTO_APPROVE']).to eq 'true'
        expect(Post.count).to eq(0)
        post "/api/post", { token: @token, url: 'http://example.com/mypic.jpg', tag: 'My pic. Enjoy...' }.to_json
      end

      after :each do
        ENV['AUTO_APPROVE'] = @cached_auto_approve
      end

      it "enters an automatically approved image into database" do
        expect(Post.count).to eq(1)
        post = Post.last
        expect(post.approved).to be true
      end

      it "returns 200 with success message" do
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['message']).to eq("Image submitted successfully")
      end

      it "creates the record in the database" do
        expect(Post.count).to eq(1)
        post = Post.last
        expect(post.approved).to be true
        expect(post.agent).to eq(@another_agent)
        expect(post.url).to eq('http://example.com/mypic.jpg')
        expect(post.tag).to eq('My pic. Enjoy...')
      end
    end
  end

  context 'regular trusted agent logged in' do
    before :each do
      expect(ENV['AUTO_APPROVE'] == false || ENV['AUTO_APPROVE'] == nil).to be true
      @another_agent = create(:another_agent)
      expect(@another_agent.trusted).to be true

      post "/api/auth", { email: @another_agent.email, password: 'secret' }.to_json
      expect(last_response.status).to eq(200)
      @token = JSON.parse(last_response.body)['token'] 
    end

    describe 'unsuccessful image submission' do
      describe 'no image URL provided' do
        before :each do
          expect(Post.count).to eq(0)
          post "/api/post", { token: @token, tag: 'My pic. Enjoy...' }.to_json
        end

        it "does not enter image into database" do
          expect(Post.count).to eq(0)
        end

        it "returns 400 with error message" do
          expect(last_response.status).to eq(400)
          expect(JSON.parse(last_response.body)['error']).to eq("Url can't be blank")
        end
      end

      describe 'no image tag provided' do
        before :each do
          expect(Post.count).to eq(0)
          post "/api/post", { token: @token, url: 'http://example.com/mypic.jpg' }.to_json
        end
    
        it "does not enter image into database" do
          expect(Post.count).to eq(0)
        end

        it "returns 400 with error message" do
          expect(last_response.status).to eq(400)
          expect(JSON.parse(last_response.body)['error']).to eq("Tag can't be blank")
        end 
      end
    end

    describe 'image submission' do
      before :each do
        expect(Post.count).to eq(0)
        post "/api/post", { token: @token, url: 'http://example.com/mypic.jpg', tag: 'My pic. Enjoy...' }.to_json
      end

      it "enters unapproved image into database" do
        expect(Post.count).to eq(1)
        post = Post.last
        expect(post.approved).to be true
      end

      it "returns 200 with success message" do
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['message']).to eq("Image submitted successfully")
      end

      it "creates the record in the database" do
        expect(Post.count).to eq(1)
        post = Post.last
        expect(post.approved).to be true
        expect(post.agent).to eq(@another_agent)
        expect(post.url).to eq('http://example.com/mypic.jpg')
        expect(post.tag).to eq('My pic. Enjoy...')
      end

    end
  end
end
