require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'fakeweb'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'agcod'

begin require "redgreen" rescue Exceptions; end

FakeWeb.allow_net_connect = false

require "macros/configuration"

class Test::Unit::TestCase
  def register_response(path, fixture)
    
  end

  def xml_fixture_path(fixture)
    File.join(File.dirname(__FILE__), "fixtures", "#{fixture}.xml")
  end
end
