module Agcod
  class CancelGiftCard < Agcod::Request
    include Agcod::OptionValidators

    def initialize(options = {})
      @action = "CancelGiftCard"
      @required_options = ["request_id", "response_id"]
      @options = options
      @required_options.each do |r|
        validate_length_of(r, "min" => 1, "max" => 19)
      end

      super

      @parameters["gcCreationRequestId"] = Agcod::Configuration.partner_id.to_s + options["request_id"].to_s
      @parameters["gcCreationResponseId"] = options["response_id"]

    end
  end
  
end
