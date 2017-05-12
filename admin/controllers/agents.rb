YesOrNo::Admin.controllers :agents do
  get :index do
    @title = "Agents"
    page = params[:page] || 1
    @agents = Agent.page(page)
    render 'agents/index'
  end

  get :show, :map => "/agent/:id" do
    @title = "Agent posts"
    @agent = Agent.find(params[:id])
    page = params[:page] || 1
    @posts = @agent.posts.page(page).order('approved ASC')
    render 'agent/show'
  end

  get :new do
    @title = pat(:new_title, :model => 'agent')
    @agent = Agent.new
    render 'agents/new'
  end

  post :create do
    @agent = Agent.new(params[:agent])
    if @agent.save
      @title = pat(:create_title, :model => "agent #{@agent.id}")
      flash[:success] = pat(:create_success, :model => 'Agent')
      params[:save_and_continue] ? redirect(url(:agents, :index)) : redirect(url(:agents, :edit, :id => @agent.id))
    else
      @title = pat(:create_title, :model => 'agent')
      flash.now[:error] = pat(:create_error, :model => 'agent')
      render 'agents/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "agent #{params[:id]}")
    @agent = Agent.find(params[:id])
    if @agent
      render 'agents/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'agent', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "agent #{params[:id]}")
    @agent = Agent.find(params[:id])
    if @agent
      if @agent.update_attributes(params[:agent])
        flash[:success] = pat(:update_success, :model => 'Agent', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:agents, :index)) :
          redirect(url(:agents, :edit, :id => @agent.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'agent')
        render 'agents/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'agent', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Agents"
    agent = Agent.find(params[:id])
    if agent
      if agent.destroy
        flash[:success] = pat(:delete_success, :model => 'Agent', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'agent')
      end
      redirect url(:agents, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'agent', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Agents"
    unless params[:agent_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'agent')
      redirect(url(:agents, :index))
    end
    ids = params[:agent_ids].split(',').map(&:strip)
    agents = Agent.find(ids)
    
    if Agent.destroy agents
    
      flash[:success] = pat(:destroy_many_success, :model => 'Agents', :ids => "#{ids.join(', ')}")
    end
    redirect url(:agents, :index)
  end

  patch :toggle_trusted, :map => "/agents/:id/toggle" do
    content_type :json
    agent = Agent.find(params[:id])
    agent.trusted = !agent.trusted
    agent.save
    { trusted: agent.trusted }.to_json
  end
end
