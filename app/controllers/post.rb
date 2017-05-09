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
    @agent = Agent.find_by(id: session[:agent_id]) || Agent.new
    @post = Post.find(params[:id])
    render :show
  end

  #
  # create
  #
  post :create, map: "/post" do
    @agent = Agent.find_by(id: session[:agent_id])
    admin = Account.find_by(email: @agent.email)

    params[:agent_id] = @agent.id

    @post = Post.new(params.except('authenticity_token'))
    @post.approved = true if admin.present?

    if @post.save
      flash[:success] = admin.present? ? 'Image submitted' : 'Image submitted for review'
      redirect "/post/#{@post.id}"
    else
      flash[:error] = @post.errors.full_messages.map { |msg| "#{msg}" }.join("<br>")
      redirect "/agents/#{@agent.id}/posts"
    end
  end

  post :deapprove, map: "/post/deapprove" do
    content_type :json
    post = Post.find(params[:id])
    post.approved = false
    post.save
    { isOwner: post.agent == current_agent, url: post.url }.to_json
  end

  #
  # Yes/No decision routes
  #
  post :answer, map: "/post/:answer" do
    halt(403, 'Log in to vote') unless logged_in?
    @agent = Agent.find_by(id: session[:agent_id])
    post = Post.find(params[:id])
    @agent.vote params[:answer] == 'yes', post
    { nos: post.nos, yeses: post.yeses, rating: post.rating }.to_json
  end

  #
  # delete
  #
  delete :delete, :map => "/post/:id" do
    @post = Post.find(params[:id])
    halt(403, 'Log in to vote') unless logged_in? && @post.agent_id == session[:agent_id]
    if @post.delete
      flash[:success] = "Post deleted"
    end
    redirect to("/agents/#{@post.agent_id}")
  end
 
  #
  # search
  #
  get :search, :map => "/post/search/:tag" do
    page = params[:page] || 1
    @agent = Agent.find_by(id: session[:agent_id]) || Agent.new
    @posts = Post.where("tag LIKE ?", "%##{params[:tag]}%").page(page)
    render :landing
  end
 
end
