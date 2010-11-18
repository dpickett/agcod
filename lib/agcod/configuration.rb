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
      attr_accessor :logger

      def load(app_root = nil, env = nil)
        if app_root
          @app_root = app_root
        else
          @app_root = Rails.root if defined?(Rails)
        end
        
        if @app_root.nil? || 
          !FileTest.exists?(config_filename = File.join(@app_root, 'config', 'agcod.yml'))
          
          raise Error::ConfigurationError, "Configuration for AGCOD not found" 
        end

        config_file = File.read(config_filename)

        environment = Rails.env if defined?(Rails)
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
