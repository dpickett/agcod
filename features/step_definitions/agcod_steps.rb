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

When /^I send the request$/ do
  @request.submit
end

Then /^it should be successful$/ do
  require "ruby-debug"
  assert @request.successful?
end

Then /^I should get a response id$/ do
  assert_not_nil @request.response_id
end

Then /^I should get a claim code$/ do
  assert_not_nil @request.claim_code
end

