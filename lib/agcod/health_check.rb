module Agcod
  class HealthCheck < Agcod::Request
    def initialize
      @action = "HealthCheck"
      super
    end
  end
end