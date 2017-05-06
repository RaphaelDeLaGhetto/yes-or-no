# Helper methods defined here can be accessed in any controller or view in the application

module YesOrNo
  class App
    module PostHelper
      #
      # Wraps anything prefixed with a hash in an anchor tag
      #
      # @param string
      #
      # @returns string
      #
      def get_hash_tags(str)
        str.gsub(/#(\w+)/i) do |tag|
          "<a href='/post/search/#{tag[1..-1]}'>#{tag}</a>"
        end
      end
    end

    helpers PostHelper
  end
end
