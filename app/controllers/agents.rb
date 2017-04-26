require 'securerandom'
require 'bcrypt'
YesOrNo::App.controllers :agents do
  
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

 
  get :new do
    redirect '/' if logged_in?
    @agent = Agent.new
    render 'agents/new'
  end

  post :create do
    confirmation = SecureRandom.hex(10)
    @agent = Agent.find_by(email: params[:agent][:email])

    if @agent.nil?
      @agent = Agent.new(email: params[:agent][:email], confirmation: confirmation)
    else
      @agent.confirmation = confirmation
    end

    if @agent.save
      deliver(:confirmation, :confirmation_email, @agent, confirmation)
      flash[:success] = 'Check your email to set your password'
      redirect('/')
    else
      render :new
    end
  end

  get :confirm, :map => '/agents/:id/confirm/:code' do
    @agent = Agent.find_by(id: params[:id])
    halt(404) if @agent.nil?
    if @agent.confirmation == params[:code]
      render :confirm
    else
      flash[:error] = 'That code is either invalid or expired. Enter email to reset password or signup.'
      redirect '/agents/new'
    end
  end

  patch :confirm do
    @agent = Agent.find_by(id: params[:id])

    halt(404) if @agent.nil?

    flash.now[:error] = 'Password cannot be blank' if params[:agent][:password].blank?

    @agent.password = params[:agent][:password]
    @agent.confirmation_hash = nil 

    if !flash[:error] && @agent.save
      session[:agent_id] = @agent.id
      redirect '/'
    else
      render :confirm
    end
  end

  get :index, :with => :id do
    redirect('/login') if !logged_in?
    @agent = Agent.find_by(id: session[:agent_id])

    page = params[:page] || 1
    @posts = @agent.posts.page(page).order('created_at DESC')
    @show_form = true;
    render :show
  end
 
  get :answer, map: "/agents/:id/:answer" do
    redirect('/login') if !logged_in?
    @agent = Agent.find_by(id: session[:agent_id])

    page = params[:page] || 1
    @posts = Post.joins(:votes).where(votes: { yes: params[:answer] == 'yeses', agent: @agent }).page(page).order('created_at DESC')

    @show_form = false;
    render :show
  end
end
