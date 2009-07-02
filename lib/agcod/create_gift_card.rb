module Agcod
  class CreateGiftCard < Agcod::Request
    include Agcod::OptionValidators

    def initialize(options = {})
      @action = "CreateGiftCard"
      super

      validate_greater_than("value", 0)
      validate_length_of("request_id", {"max" => 19, "min" => 1})

      #can't have a nonexistant or 0 value for the gift card
      @parameters["gcValue.amount"] = options["value"]

      @value = options["value"]

      #must have a unique identifier for the request
      @parameters["gcCreationRequestId"]  = Agcod::Configuration.partner_id + options["request_id"].to_s

      @parameters["gcValue.currencyCode"] = options["currency_code"] || "USD" 

    end

    def process_response
      super
      if self.successful?
        @claim_code = self.xml_response.root.elements["gcClaimCode"].text
        @response_id = self.xml_response.root.elements["gcCreationResponseId"].text
      end
    end

    attr_reader :claim_code, :response_id, :value

    def to_yaml(name)
      {"response_id" => self.response_id, 
        "request_id" => self.request_id, 
        "claim_code" => self.claim_code,
        "value" => self.value,
        "timestamp" => self.timestamp
      }.to_yaml(name)
    end
  end
end
