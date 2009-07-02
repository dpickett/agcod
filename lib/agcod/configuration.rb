module Agcod
  class Configuration
    REQUIRED_OPTIONS = ["access_key", 
      "secret_key",
      "partner_id",
      "uri",
      "discount_percentage"
    ]    
    
    class << self
      attr_reader :options
      def load(app_root = nil, env = nil)
        if app_root
          @app_root = app_root
        else
          @app_root = RAILS_ROOT if defined?(RAILS_ROOT)
        end
        
        if @app_root.nil? || 
          !FileTest.exists?(config_filename = File.join(@app_root, 'config', 'agcod.yml'))
          
          raise Error::ConfigurationError, "Configuration for AGCOD not found" 
        end

        config_file = File.read(config_filename)

        environment = RAILS_ENV if defined?(RAILS_ENV)
        environment = env if env

        @options = YAML.load(config_file)[environment]
        validate_options
        @options
      end

      def set(opt = {})
        @options ||= {}
        @options.merge!(opt)

        validate_options
        @options
      end
     
      def access_key
        @options["access_key"]
      end

      def secret_key
        @options["secret_key"]
      end

      def partner_id
        @options["partner_id"]
      end

      def uri
        @options["uri"]
      end

      def discount_percentage
        @options["discount_percentage"]
      end

      private
      
      def validate_options
        REQUIRED_OPTIONS.each do |opt|
          if options[opt].nil? || options[opt] == ""
            raise Error::ConfigurationError, "#{opt} was not specified" 
          end
        end    
      end
    end
  end
end