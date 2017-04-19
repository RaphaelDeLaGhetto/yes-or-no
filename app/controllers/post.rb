YesOrNo::App.controllers :post do
  
  #
  # index
  #
  get :index do
    page = params[:page] || 1
    @posts = Post.order_by_rating(page)

    @can_vote = false
    render :landing
  end

  #
  # show
  #
  get :show, :map => "/post/:id" do
    @post = Post.find(params[:id])
    render :show
  end

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
