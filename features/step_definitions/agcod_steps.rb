Given /^I have access to the AGCOD web service$/ do
  Agcod::Configuration.load(File.join(File.dirname(__FILE__), "..", "support", "app_root"), "cucumber")
  assert_not_nil Agcod::Configuration.access_key
end

Given /^I want to send request \"(.*)\"/ do |request_number|
  req = get_request(request_number)
  @options ||= {} 
  @request = Agcod::CreateGiftCard.new(req.merge(@options))
end

Given /^I am logging transactions$/ do
  @logger = Logger.new(File.join(FileUtils.pwd, "agcod_cucumber.log"))
  Agcod::Configuration.logger = @logger
end

Given /^I want to send a health check request$/ do
  @request = Agcod::HealthCheck.new
end

Given /^I've sent request \"(.*)\"$/ do |request_number|
  req = get_request(request_number)
  @prior_request = Agcod::CreateGiftCard.new("value" => req["value"].to_f,
   "request_id" => req["request_id"])
  @prior_request.submit
  dump_request(@prior_request)
end

Given /^I want to cancel the gift card requested$/ do
  @request = Agcod::CancelGiftCard.new("request_id" => @prior_request.request_id, 
    "response_id" => @prior_request.response_id)
end

Given /^I want to void the gift card requested$/ do
  @request = Agcod::VoidGiftCardCreation.new("request_id" => @prior_request.request_id)
end


Given /^the request was successful$/ do
  assert @prior_request.successful?
end

Given /^I want to create a gift card with the same request id$/ do
  @request = Agcod::CreateGiftCard.new("value" => 40, "request_id" => @prior_request.request_id)
  @dont_dump_request = true
end

Given /^I want to cancel request "([^\"]*)"$/ do |req_num|
  req = get_request(req_num)
  @options ||= {}
  @request = Agcod::CancelGiftCard.new(req.merge(@options))
end

Given /^I want to void request "([^\"]*)"$/ do |req_num|
  req = get_request(req_num)
  @options ||= {}
  @request = Agcod::VoidGiftCardCreation.new(req.merge(@options))
end


Given /^I specify response_id "([^\"]*)"$/ do |response_id|
  @options ||= {}
  @options["response_id"] = response_id
end

Given /^I specify the currency of "([^\"]*)"$/ do |currency|
  @options ||= {}
  @options["currency_code"] = currency
end



Then /^I should not receive a successful response$/ do
  assert !@request.successful?
end

When /^I send the request$/ do
  @request.submit
  dump_request(@request) if @request.is_a?(Agcod::CreateGiftCard) && !@dont_dump_request
  @dont_dump_request = false if @dont_dump_request
end

Then /^I should receive a successful response$/ do
  assert @request.successful?
end

Then /^I should get a response id$/ do
  assert_not_nil @request.response_id
end

Then /^I should get a claim code$/ do
  assert_not_nil @request.claim_code
end


def cert_fixture(req_num)
  File.join(
    File.dirname(__FILE__), "..", "support", "certification_requests", "#{req_num}.yml"
  )
end

def get_request(req_num)
  YAML.load(File.read(cert_fixture(req_num)))
end

def dump_request(req)
  req_num = req.request_id[0..0]

  
  req_hash = {
    "request_id" => req.request_id,
    "value" => req.value,
    "response_id" => req.response_id,
    "claim_code" => req.claim_code
  }

  FileUtils.rm_f(cert_fixture(req_num))
  File.open(cert_fixture(req_num), "w") do |f|
    f.puts req_hash.to_yaml
  end
end
