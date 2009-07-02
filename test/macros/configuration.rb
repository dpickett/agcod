class Test::Unit::TestCase
  def self.should_require_config_options(options)
    valid_options = {
      "access_key" => "45127185235",
      "secret_key" => "4321542523453454325j",
      "partner_id" => "SomebodySpecial",
      "uri"        => "https://agcws-gamma.amazon.com/",
      "discount_percentage" => 0.04
    }
    
    options = [options] unless options.is_a?(Array)

    options.each do |option|
      should "require #{option} as a configuration option" do
        assert_raise Agcod::Error::ConfigurationError do
          Agcod::Configuration.set(valid_options.merge({
            option => ""                       
          }))
        end
      end 
    end
          
  end
end
