require 'opal'
require "opal-activesupport"

require "opal/react/jsx_support"
require "opal/react/source"

Opal.append_path File.expand_path('../../../opal', __FILE__).untaint
Opal.append_path File.expand_path('../../../vendor', __FILE__).untaint
