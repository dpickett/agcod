module Agcod
  module OptionValidators
    def validate_timestamp
      if @options["timestamp"].nil? || !@options["timestamp"].instance_of?(Time)
        raise Agcod::Error::InvalidParameter, "Invalid Timestamp for record #{@options["record_id"]}"
      end
    end

    private
    def validate_presence_of(option_name)
      if @options[option_name].nil? || @options[option_name].to_s.blank?
        raise Agcod::Error::InvalidParameter, "#{option_name} not specified"
      end
    end

    def validate_length_of(option_name, size_options)
      size_options["min"] ||= 0
      size_options["max"] ||= 10000
      if @options[option_name].nil? || 
          @options[option_name].to_s.size < size_options["min"] || 
          @options[option_name].to_s.size > size_options["max"]

        raise Agcod::Error::InvalidParameter, "#{option_name} has an invalid length"
      end
    end

    def validate_greater_than(option_name, number)
      if @options[option_name].nil? || @options[option_name].to_f <= number
        raise Agcod::Error::InvalidParameter, "#{option_name} must be greater than #{number} for record #{@options["record_id"]}"
      end
    end
  end
end
