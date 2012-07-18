$LOAD_PATH.unshift(File.dirname(__FILE__))

require "net/http"
require "net/https"
require 'rexml/document'

require "uri"
require "cgi"
require "base64"
require 'openssl'
require "cgi"
require "logger"

require "agcod/error/invalid_parameter"
require "agcod/error/configuration_error"
require "agcod/option_validators"

require "agcod/configuration"
require "agcod/request"

require "agcod/cancel_gift_card"
require "agcod/create_gift_card"
require "agcod/health_check"
require "agcod/void_gift_card_creation"
