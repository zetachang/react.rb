require 'spec_helper'

if opal?
describe 'the required_param macro' do
  it "can be used to declare a required param"                              # required_param :foo
  it "can have a simple type"                                               # required_param :foo, type: String
  it "can use the [] notation for arrays"                                   # required_param :foo, type: []
  it "can use the [] notation for arrays of a specific type"                # required_param :foo, type: [String]
  it "can convert a json hash to a type"                                    # required_param :foo, type: BazWoggle # requires a BazWoggle conversion be provided
  it "will alias a Proc type param"                                         # required_param :foo, type: Proc # we can just say foo(...) to call the proc
  it "will bind a two way linkage to an observable param"                   # required_param :foo, type: React::Observable # defines foo, and foo! bound to the observer
    # you can create an observable simply by passing the value of some state!
end
describe 'the optional_param macro' do
  # works just like a required_param, and
  it "can have a default value"                                             # optional_param :foo, type: String, default: ""
end
end
