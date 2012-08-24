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

  context 'retrying a create gift card request' do
    setup do
      Agcod::Configuration.load(File.join(File.dirname(__FILE__), "..", "app_root"), "test")
      @request = Agcod::CreateGiftCard.new('value' => 100, 'request_id' => 12345)
    end

    should 'use response of retried request' do
      uri = URI.parse(@request.request_url)
      register_response %r{^#{ uri.scheme }://#{ uri.host }}, %w( create_gift_card/resend create_gift_card/resend create_gift_card/success )
      @request.submit
      assert_equal "SUCCESS", @request.status
    end
  end
end
