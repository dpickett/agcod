require "test_helper"

class Agcod::RequestTest < Test::Unit::TestCase
  context 'a health check request' do
    setup do
      Agcod::Configuration.load(File.join(File.dirname(__FILE__), "..", "app_root"), "test")
      @request = Agcod::HealthCheck.new
    end

    should 'read response body' do
      register_response @request.request_url, "health_check/success"
      @request.submit
      assert_equal "SUCCESS", @request.status
    end
  end
end
