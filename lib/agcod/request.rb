module Agcod
  class Request
    def initialize(options = {})
      @request = ""
      @response = ""
      @status = ""
      @parameters = {}
      @options = options
    end

    def submit
      #action must be specified so raise an exception if it has not been populated
      if self.action.nil?
        raise "Action not specified"
      end

      #form the request GET parameter string
      @request = build_sorted_and_signed_request_string

      send_request

      process_response
    end

    def successful?
      self.sent && self.errors.size == 0 && self.status == "SUCCESS"
    end

    attr_reader :errors, :request_id, :sent, :action, :request, :parameters, :response, :xml_response, :status, :timestamp

    def sign_string(string_to_sign)
      #remove all the = and & from the serialized string
      sanitized_string = string_to_sign.gsub(/=|&/, "")
      # puts sanitized_string
      sha1 = HMAC::SHA1::digest(Agcod::Configuration.secret_key, sanitized_string)

      #Base64 encoding adds a linefeed to the end of the string so chop the last character!
      CGI.escape(Base64.encode64(sha1).chomp)
    end

    def request_id
      @options["request_id"]
    end

    def response_id
      @response_id || @options["response_id"]
    end

    protected 

    def process_response
      parse_response

      @errors = []

      self.xml_response.root.elements.each("Error") do |e|
        @errors << e.elements["Message"].text
      end

      @status = self.xml_response.root.elements["Status/statusCode"].text unless xml_response.root.elements["Status/statusCode"].nil?

      #something happened before it got to ACGWS (most likely a signature problem)
      @status = "FAILURE" if self.errors.size > 0 && self.status.blank?

      @request_id = xml_response.root.elements["RequestID"].text unless xml_response.root.elements["RequestID"].nil?
    end

    def parse_response
      @xml_response ||= REXML::Document.new(self.response)
    end

    private
    def send_request
      #send the request
      uri = URI.parse(Agcod::Configuration.uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      net_response, @response = http.get(uri.path + "?" + self.request)

      @sent = true
    end

    def default_parameters
      @timestamp = Time.now.utc
      {
        "Action" => self.action,
        "AWSAccessKeyId" => Agcod::Configuration.access_key,
        "SignatureVersion" => "1",
        "MessageHeader.recipientId" => "AMAZON",
        "MessageHeader.sourceId" => Agcod::Configuration.partner_id,
        "MessageHeader.retryCount" => "0",
        "MessageHeader.contentVersion" => "2008-01-01",
        "MessageHeader.messageType" => self.action + "Request",
        "Timestamp" => @timestamp.strftime("%Y-%m-%dT%H:%M:%S") + ".000Z"
      }
    end

    def build_sorted_and_signed_request_string
      params_to_submit = default_parameters.merge(self.parameters)

      unencoded_key_value_strings = []
      encoded_key_value_strings = []
      sort_parameters(params_to_submit).each do |p|
        unencoded_key_value_strings << p[0].to_s + p[1].to_s

        if p[0] =~ /Timestamp/i
          encoded_value = p[1]
        else
          encoded_value = CGI.escape(p[1].to_s)
        end
        encoded_key_value_strings << p[0].to_s + "=" + encoded_value
      end

      signature = sign_string(unencoded_key_value_strings.join(""))
      encoded_key_value_strings.insert(encoded_key_value_strings.index("SignatureVersion=1") + 1 , "Signature=" + signature)
      encoded_key_value_strings.join("&")
    end


    def sort_parameters(params)
      key_value_strings = []
      params.sort{|a, b| a[0].downcase <=> b[0].downcase }
    end

  end
end
