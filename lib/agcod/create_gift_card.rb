module Agcod
  class CreateGiftCard < Agcod::Request
    include Agcod::OptionValidators

    def initialize(options = {})
      @action = "CreateGiftCard"
      @attempts = 0
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
      else
        if should_attempt_retry?
          sleep(retry_interval)
          void_on_resend
          attempt_retry
        end
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

    protected
    def send_request
      begin
        super
      rescue SocketError,
        Timeout::Error,
        ActiveResource::TimeoutError,
        Errno::ECONNREFUSED,
        Errno::EHOSTDOWN,
        Errno::EHOSTUNREACH

        sleep(retry_interval)
        attempt_to_void_with_retry
      end
    end

    def has_retry_error_code?
      self.xml_response.root.elements["Status/errorCode"] &&
      self.xml_response.root.elements["Status/errorCode"].text == "E100"
    end

    def should_attempt_retry?
      has_retry_error_code? && @attempts < retry_limit
    end

    def retry_limit
      Agcod::Configuration.retry_limit || 1
    end

    def retry_interval
      Agcod::Configuration.retry_interval || 5
    end

    def attempt_retry
      @attempts += 1
      submit
    end

    private
    def void_on_resend
      if has_retry_error_code? && ! @resend_void_sent
        @resend_void_sent = true
        attempt_to_void
      end
    end

    def attempt_to_void_with_retry
      begin
        attempt_to_void
      rescue SocketError,
        Timeout::Error,
        ActiveResource::TimeoutError,
        Errno::ECONNREFUSED,
        Errno::EHOSTDOWN,
        Errno::EHOSTUNREACH
          sleep(retry_interval)
          attempt_to_void
      end
    end

    def attempt_to_void
      Agcod::VoidGiftCardCreation.new("request_id" => self.request_id).submit
    end
  end
end
