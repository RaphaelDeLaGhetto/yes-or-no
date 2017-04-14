# Helper methods defined here can be accessed in any controller or view in the application

module YesOrNo
  class App
    module AgentsHelper
      def logged_in?
        !session[:agent_id].nil?
      end 
    end

    helpers AgentsHelper
  end
end
