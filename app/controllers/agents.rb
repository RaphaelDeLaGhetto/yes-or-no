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
    @agent = Agent.new(params[:agent])
    if @agent.save
      redirect('/')
    else
      render 'agents/new'
    end
  end

end
