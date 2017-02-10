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

  # get :foo, :with => :id do
  #   "Maps to url '/foo/#{params[:id]}'"
  # end

  # get '/example' do
  #   'Hello world!'
  # end

  #
  # create
  #
  post :create, map: "/post" do
    @post = Post.new(params.except('authenticity_token'))
    if @post.save
      flash[:success] = 'Image submitted for review'
      redirect '/'
    else
      erb :landing
    end
  end
 

end
