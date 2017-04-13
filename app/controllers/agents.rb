require 'securerandom'
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
    @agent = Agent.new
    render 'agents/new'
  end

  post :create do
    confirmation = SecureRandom.hex(10)
    @agent = Agent.new(email: params[:agent][:email], confirmation: confirmation.to_s)
    if @agent.save
      deliver(:confirmation, :confirmation_email, @agent.email, confirmation)
      redirect('/')
    else
      render 'agents/new'
    end
  end

end
