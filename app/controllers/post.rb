YesOrNo::App.controllers :post do
  
  # get :index, :map => '/foo/bar' do
  #   session[:foo] = 'bar'
  #   render 'index'
  # end

  # get :sample, :map => '/sample/url', :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  #
  # show
  #
  get :show, :map => "/post/:id" do
    @post = Post.find(params[:id])
    render :show
  end

  # get '/example' do
  #   'Hello world!'
  # end

  #
  # create
  #
  post :create, map: "/post" do
    @agent = Agent.find_by(id: session[:agent_id])
    params[:agent_id] = @agent.id

    @post = Post.new(params.except('authenticity_token'))
    if @post.save
      flash[:success] = 'Image submitted for review'
      redirect "/post/#{@post.id}"
    else
      erb :landing
    end
  end

  #
  # Yes/No decision routes
  #
  post :answer, map: "/post/:answer" do
    halt(403, 'Log in to vote') unless logged_in?
    @agent = Agent.find_by(id: session[:agent_id])
    post = Post.find(params[:id])
    @agent.vote params[:answer] == 'yes', post
    { rating: post.rating }.to_json
  end

end
