require "test_helper"

class Agcod::ConfigurationTest < Test::Unit::TestCase
  context "an agcod configuration" do
    setup do
      @valid_app_root = File.join(File.dirname(__FILE__), "..", "app_root")
      @valid_options = {
        "access_key" => "45127185235",
        "secret_key" => "4321542523453454325j",
        "partner_id" => "SomebodySpecial",
        "uri"        => "https://agcws-gamma.amazon.com/",
        "discount_percentage" => 0.04
      }
    end

    should "raise an error if the configuration file isn't specified" do
      assert_raise Agcod::Error::ConfigurationError do 
        Agcod::Configuration.load
      end
    end

    should "raise an error if the configuration file isn't found" do
      assert_raise Agcod::Error::ConfigurationError do
        Agcod::Configuration.load("/foo4258fast43")
      end
    end

    should "read configuration from a supplied app root" do
      Agcod::Configuration.load(File.join(File.dirname(__FILE__), "..", "app_root"), "test")
      Agcod::Configuration::REQUIRED_OPTIONS.each do |opt|
        assert_not_nil Agcod::Configuration.send(opt)
      end
    end
    
    should "allow me to set config options at runtime" do
      Agcod::Configuration.set(@valid_options)
      assert_equal Agcod::Configuration.access_key, @valid_options["access_key"]
    end

    should_require_config_options [
      "access_key", 
      "secret_key", 
      "partner_id", 
      "uri",
      "discount_percentage"
    ]
  end
end
