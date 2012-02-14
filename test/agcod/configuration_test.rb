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

    should "raise an error if the environment key is not included in the config file" do
      assert_raise Agcod::Error::ConfigurationError do
        Agcod::Configuration.load(File.join(File.dirname(__FILE__), "..", "app_root"), "staging")
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

  context "agcod logging" do
    setup do
      configure_with_valid_options
      @log_path = File.join(File.dirname(__FILE__), "..", "log", "test.log")
      FileUtils.mkdir_p(File.dirname(@log_path))
      FileUtils.touch(@log_path)
      @logger = Logger.new(@log_path)
      @logger.level = Logger::DEBUG

      Agcod::Configuration.logger = @logger

      FakeWeb.allow_net_connect = false

      @request = Agcod::CreateGiftCard.new("request_id" => 34234, "value" => 12)
      @request.stubs(:response_id).returns(4323535)
      @request.stubs(:send_request)
      @request.stubs(:process_response)
      @request.stubs(:claim_code).returns(342145)
      @request.submit
    end

    teardown do
      FileUtils.rm_f(@log_path)
    end

    should "allow me to define a logger for logging requests" do
      @logger = Logger.new(STDOUT)
      Agcod::Configuration.logger =  @logger
      assert_equal @logger, Agcod::Configuration.logger
    end

    should "log request operation names" do
      assert_match /CreateGiftCard/, File.read(@log_path)
    end

    should "log request ids when applicable" do
      assert_match /#{@request.request_id}/, File.read(@log_path)
    end

    should "log response ids when applicable" do
      assert_match /#{@request.response_id}/, File.read(@log_path)
    end

    should "og claim code when applicable" do
      assert_match /#{@request.claim_code}/, File.read(@log_path)
    end
  end

  def configure_with_valid_options
    @valid_options = {
      "access_key" => "45127185235",
      "secret_key" => "4321542523453454325j",
      "partner_id" => "SomebodySpecial",
      "uri"        => "https://agcws-gamma.amazon.com/",
      "discount_percentage" => 0.04
    }
    Agcod::Configuration.set(@valid_options)
  end
end
