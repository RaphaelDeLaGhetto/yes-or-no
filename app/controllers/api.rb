YesOrNo::App.controllers :api, :provides => [:json] do

  post :auth, map: "/api/auth" do
    agent = Agent.find_by_email(params[:email])
    if agent && agent.password == params[:password]
      hmac_secret = 'my$ecretK3y'
      response.status = 200
      JWT.encode({agent_id: agent.id}, hmac_secret, 'HS256')
    else
      response.status = 403
    end
  end

  #
  # create
  #
  post :create, map: "/api/post" do
    if params[:token].nil?
      response.status = 403
      return { error: 'Invalid token' }.to_json
    end
    decoded_token = JWT.decode params[:token], ENV['HMAC_SECRET'], false, { :algorithm => 'HS256' }

    agent = Agent.find(decoded_token[0]['agent_id'])
    admin = Account.find_by(email: agent.email)

    params[:agent_id] = agent.id

    post = Post.new(params.except('token', 'format'))
    approved = admin.present? || agent.trusted || ENV['AUTO_APPROVE'] == 'true'
    post.approved = true if approved

    if post.save
      { message: approved ? 'Image submitted successfully' : 'Image submitted for review' }.to_json
#      flash[:success] = approved ? 'Image submitted successfully' : 'Image submitted for review'
#      redirect "/post/#{@post.id}"
    else
      response.status = 400
      { error: post.errors.full_messages.map { |msg| "#{msg}" }.join(". ") }.to_json
#      flash[:error] = @post.errors.full_messages.map { |msg| "#{msg}" }.join(". ")
#      redirect "/agents/#{@agent.id}/posts"
    end
  end

 
  # get :index, :map => '/foo/bar' do
  #   session[:foo] = 'bar'
  #   render 'index'
  # end

  # get :sample, :map => '/sample/url', :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   "Maps to url '/foo/#{params[:id]}'"
  # end

  # get '/example' do
  #   'Hello world!'
  # end
  

end
