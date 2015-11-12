require 'spec_helper'

if opal?
describe React::NativeLibrary do
  it "will import a React.js library into the Ruby name space"              # class BS < NativeLibrary; imports 'ReactBootstrap'; end
  it "exclude specific components from a library"                           # exclude "Modal" # can't access BS.Modal
  it "rename specific components from a library"                            # rename "Modal" => "FooBar"  # BS.FooBar connects to ReactBootstrap.Modal
  it "can importan multiple libraries into one class"                       
end
end
