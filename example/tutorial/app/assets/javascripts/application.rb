#assets/javascript/application.rb
# only put files that are browser side only.

require 'components'  # this pulls in your components from the components.rb manifest file  
require 'jquery'      # you need both these files to access jQuery from Opal
require 'opal-jquery' # they must be in this order, and after the components require
require 'browser'     # opal access to browser specific methods (such as setTimer)
require 'react_ujs'   # this is required and is part of the prerendering system
# whatever else you might need here

