$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'arg_parser'
require 'config'
require 'cygwin_util'
require 'executor'
require 'file_util'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  
end
