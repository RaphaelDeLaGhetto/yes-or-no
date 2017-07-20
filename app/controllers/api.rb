YesOrNo::App.controllers :api, :provides => [:json] do

  #
  # authenticate
  #
  post :auth, map: "/api/auth", :csrf_protection => false do
    json = JSON.parse(request.body.read)
    agent = Agent.find_by_email(json['email'])
    if agent && agent.password == json['password']
      hmac_secret = ENV['HMAC_SECRET']
      response.status = 200
      { token: JWT.encode({agent_id: agent.id}, hmac_secret, 'HS256'),
        #create: "#{absolute_url(:api, :create)}" }.to_json
        create: "#{uri url(:api, :create)}" }.to_json
    else
      response.status = 403
      return { error: 'Could not authenticate' }.to_json
    end
  end

  #
  # create
  #
  post :create, map: "/api/post", :csrf_protection => false do
    json = JSON.parse(request.body.read)

    if json['token'].nil?
      response.status = 403
      return { error: 'Invalid token' }.to_json
    end
    decoded_token = JWT.decode json['token'], ENV['HMAC_SECRET'], false, { :algorithm => 'HS256' }

    agent = Agent.find(decoded_token[0]['agent_id'])
    admin = Account.find_by(email: agent.email)

    json['agent_id'] = agent.id

    post = Post.new(json.except('token', 'format'))
    approved = admin.present? || agent.trusted || ENV['AUTO_APPROVE'] == 'true'
    post.approved = true if approved

    if post.save
      { message: approved ? 'Image submitted successfully' : 'Image submitted for review' }.to_json
    else
      response.status = 400
      { error: post.errors.full_messages.map { |msg| "#{msg}" }.join(". ") }.to_json
    end
  end
end
