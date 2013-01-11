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
      register_response %r{^#{ uri.scheme }://#{ uri.host }}, %w( create_gift_card/retry create_gift_card/success )
      @request.submit
      assert_equal "SUCCESS", @request.status
    end
  end

  context 'handle for a non-error failure' do
    setup do
      Agcod::Configuration.load(File.join(File.dirname(__FILE__), "..", "app_root"), "test")
      @request = Agcod::CreateGiftCard.new('value' => 13.57, 'request_id' => 12345)
    end

    should 'store failure from statusMessage' do
      uri = URI.parse(@request.request_url)
      register_response %r{^#{ uri.scheme }://#{ uri.host }}, %w( create_gift_card/non-error-failure create_gift_card/success )
      @request.submit
      assert_equal "FAILURE", @request.status
      assert(@request.errors.count > 0)
    end
  end

  context 'signature version 2' do
    setup do
      Agcod::Configuration.load(File.join(File.dirname(__FILE__), "..", "app_root"), "test")
      @request = Agcod::HealthCheck.new
      register_response @request.request_url, "health_check/success"
    end

    should "sort params using lexicographic byte ordering" do
      @request.submit
      proper_order = %w(AWSAccessKeyId Action MessageHeader.contentVersion MessageHeader.messageType MessageHeader.recipientId MessageHeader.retryCount MessageHeader.sourceId SignatureMethod SignatureVersion Signature Timestamp)
      assert_equal proper_order, @request.request.split("&").map{|param| param.split('=').first}
    end

    should "include SignatureMethod=HmacSHA256&SignatureVersion=2 in the query string" do
      @request.submit
      assert @request.request.include?("SignatureMethod=HmacSHA256&SignatureVersion=2")
    end

    should 'begin with the request method, http host, and path in the string to sign' do
      @request.submit
      request_string_to_sign = @request.send(:build_v2_string_to_sign, @request.send(:default_parameters).merge(@request.parameters).sort)
      assert request_string_to_sign.include?("GET\nagcws-gamma.amazon.com\n/\n")
    end

    should "use a sha256 digest" do
      d = mock('digest')
      OpenSSL::Digest::Digest.expects(:new).twice.with('sha256').returns(d)
      OpenSSL::HMAC.expects(:digest).twice.returns ""
      @request.submit
    end
  end
end
