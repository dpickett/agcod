Given /^I have access to the AGCOD web service$/ do
  Agcod::Configuration.load(File.join(File.dirname(__FILE__), "..", "support", "app_root"), "cucumber")
  assert_not_nil Agcod::Configuration.access_key
end

Given /^I want to create a gift card in the amount of \$(.*)$/ do |value|
  @value = value.to_f
  @request_id = ""
  8.times {@request_id << rand(9).to_s}

  @request = Agcod::CreateGiftCard.new("value" => @value, "request_id" => @request_id)
end

Given /^I am logging transactions$/ do
  @logger = Logger.new(File.join(FileUtils.pwd, "agcod_cucumber.log"))
  Agcod::Configuration.logger = @logger
end

Given /^I want to send a health check request$/ do
  @request = Agcod::HealthCheck.new
end

Given /^I've sent a gift card request in the amount of \$(.*)$/ do |value|
  request_id = ""
  8.times {request_id << rand(9).to_s}
  @prior_request = Agcod::CreateGiftCard.new("value" => value.to_f, "request_id" => request_id)
  @prior_request.submit
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
end

Then /^I should not receive a successful response$/ do
  assert !@request.successful?
end

When /^I send the request$/ do
  @request.submit
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

