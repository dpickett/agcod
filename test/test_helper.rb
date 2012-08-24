require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'fakeweb'
require 'mocha'

module ActiveResource
  class TimeoutError < StandardError
  end
end

class String
  def blank?
    empty?
  end
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'agcod'

begin
  require "redgreen"
rescue LoadError
end

FakeWeb.allow_net_connect = false

require "macros/configuration"

class Test::Unit::TestCase
  def register_response(uri, fixtures)
    fixtures = [fixtures].flatten.map do |f|
      { :body => IO.read(xml_fixture_path(f)) }
    end

    FakeWeb.register_uri(:get, uri, fixtures)
  end

  def xml_fixture_path(fixture)
    File.join(File.dirname(__FILE__), "fixtures", "#{fixture}.xml")
  end
end
