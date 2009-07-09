module Agcod
  class VoidGiftCardCreation < Agcod::Request
    include Agcod::OptionValidators

    def initialize(options = {})
      @action = "VoidGiftCardCreation"
      super

      validate_presence_of("request_id")

      @parameters["gcCreationRequestId"] = Agcod::Configuration.partner_id.to_s + self.request_id.to_s
    end
  end  
end
