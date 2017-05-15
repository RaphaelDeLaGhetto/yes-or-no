module YesOrNo
  class App < Padrino::Application
    use ConnectionPoolManagement
    register Padrino::Mailer
    register Padrino::Helpers
    register Padrino::Flash
    register WillPaginate::Sinatra

    enable :sessions

    ##
    # Caching support.
    #
    # register Padrino::Cache
    # enable :caching
    #
    # You can customize caching store engines:
    #
    # set :cache, Padrino::Cache.new(:LRUHash) # Keeps cached values in memory
    # set :cache, Padrino::Cache.new(:Memcached) # Uses default server at localhost
    # set :cache, Padrino::Cache.new(:Memcached, :server => '127.0.0.1:11211', :exception_retry_limit => 1)
    # set :cache, Padrino::Cache.new(:Memcached, :backend => memcached_or_dalli_instance)
    # set :cache, Padrino::Cache.new(:Redis) # Uses default server at localhost
    # set :cache, Padrino::Cache.new(:Redis, :host => '127.0.0.1', :port => 6379, :db => 0)
    # set :cache, Padrino::Cache.new(:Redis, :backend => redis_instance)
    # set :cache, Padrino::Cache.new(:Mongo) # Uses default server at localhost
    # set :cache, Padrino::Cache.new(:Mongo, :backend => mongo_client_instance)
    # set :cache, Padrino::Cache.new(:File, :dir => Padrino.root('tmp', app_name.to_s, 'cache')) # default choice
    #

    ##
    # Application configuration options.
    #
    # set :raise_errors, true       # Raise exceptions (will stop application) (default for test)
    # set :dump_errors, true        # Exception backtraces are written to STDERR (default for production/development)
    # set :show_exceptions, true    # Shows a stack trace in browser (default for development)
    # set :logging, true            # Logging in STDOUT for development and file for production (default only for development)
    # set :public_folder, 'foo/bar' # Location for static assets (default root/public)
    # set :reload, false            # Reload application files (default in development)
    # set :default_builder, 'foo'   # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, 'bar'       # Set path for I18n translations (default your_apps_root_path/locale)
    # disable :sessions             # Disabled sessions by default (enable if needed)
    # disable :flash                # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
    # layout  :my_layout            # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
    #

    ##
    # You can configure for a specified environment like:
    #
    #   configure :development do
    #     set :foo, :bar
    #     disable :asset_stamp # no asset timestamping for dev
    #   end
    #

    ##
    # You can manage errors like:
    #
    #   error 404 do
    #     render 'errors/404'
    #   end
    #
    #   error 500 do
    #     render 'errors/500'
    #   end
    #

    Dotenv.load
    #
    # Mailer config
    #
    set :delivery_method, :smtp => {
      :address         => ENV['SMTP_ADDRESS'],
      :port            => ENV['SMTP_PORT'],
      :user_name       => ENV['EMAIL_USERNAME'],
      :password        => ENV['EMAIL_PASSWORD'],
      :authentication  => :plain, # :plain, :login, :cram_md5, no auth by default
      :domain          => "localhost.localdomain" # the HELO domain provided by the client to the server
    }

    ##########
    # 2017-4-13
    # cf. with the commented test config in `spec/spec_helper.rb`. It's a lot
    # nicer to put this there, but then the admin application doesn't run for
    # the tests. I don't know why this is
    #
    if RACK_ENV == 'test'
      use RackSessionAccess::Middleware
      set :protect_from_csrf, false
      set :delivery_method, :test
    end

    after '/' do
      session[:first_login] = nil
      session[:home_visited] = true
    end

    get '/' do
      page = params[:page] || 1
      @posts = Post.where(approved: true).order('created_at DESC').page(page)
      @agent = current_agent
      @can_vote = true
      render :landing
    end

    get '/login' do
      redirect '/' if logged_in?
      @agent = Agent.new
      erb :login
    end

    post '/login' do
      @agent = Agent.find_by_email(params[:email])
      if @agent.present?
        session[:unauthenticated_agent_id] = @agent.id
        redirect '/login/password'
      end

      confirmation = SecureRandom.hex(10)
      @agent = Agent.new(email: params[:email], confirmation: confirmation)
      if @agent.save
        deliver(:confirmation, :confirmation_email, @agent, confirmation)
        session[:agent_id] = @agent.id
        flash[:success] = 'Welcome! Check your email'
        redirect '/'
      else
        erb :login
      end
    end

    get '/login/password' do
      redirect '/login' if session[:unauthenticated_agent_id].nil?
      @agent = Agent.find(session[:unauthenticated_agent_id])
      erb :password
    end

 
    post '/login/password' do
      @agent = Agent.find_by_email(params[:email])
      if @agent.password == params[:password]
        session[:agent_id] = @agent.id
        session[:first_login] = true
        @agent.tally_points
        redirect '/'
      else
        @agent.errors.add(:base, :blank, message: "Did you forget your password?")
        erb :password
      end
    end

    get '/logout' do
      session.clear
      redirect '/'
    end

    get '/about' do
      render :about
    end
  end
end
