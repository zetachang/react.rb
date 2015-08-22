#assets/javascript/application.rb

# only put files that are browser side only.

require 'components'  # this pulls in your components from the components.rb manifest file  
require 'react_ujs'   # this is required on the client side only and is part of the prerendering system

# require any thing else that is browser side only, typically  these 4 are all you need.  If you
# have client only sections of code that that do not contain requires wrap them in 
# if React::IsomorphicHelpers.on_opal_client? blocks.  

require 'jquery'           # you need both these files to access jQuery from Opal
require 'opal-jquery'      # they must be in this order, and after the components require
require 'browser/interval' # for #every, and #after methods

