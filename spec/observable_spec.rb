require "spec_helper"

describe 'React::Observable' do
  
  it "can be given a block which will be called to notify of a change" do
    tested = false
    observer = React::Observable.new(nil) { |new_value| expect(new_value).to eq(:testing_a_change); tested = true }
    observer.call(:testing_a_change)
    expect(tested).to be_truthy
  end
  
  it "will return the new_value as the value of the call" do
    observer = React::Observable.new(nil) {  }
    expect(observer.call(:testing_a_change)).to eq(:testing_a_change)
  end
  
  it "can respond to to_proc by providing a lambda wrapping the provided block" do
    tested = false
    observer = React::Observable.new(nil) { |new_value| expect(new_value).to eq(:testing_a_change); tested = true}
    observer.to_proc.call :testing_a_change
    expect(tested).to be_truthy
  end
  
  it "will return the value of its block when used as a proc call" do
    observer = React::Observable.new(nil) { :some_other_value }
    expect(observer.to_proc.call).to eq(:some_other_value)
  end
  
  it "will provide the current value to the block if the proc is called without any parameters" do
    observer = React::Observable.new(:current_value) { |new_value| new_value}
    expect(observer.to_proc.call).to eq(:current_value)
  end
  
  it "will update the current value if directly called" do
    observer = React::Observable.new(:current_value) { |new_value| new_value}
    observer.call(:new_value)
    expect(observer.to_proc.call).to eq(:new_value)
  end
  
  it "will not update the current value if called via a proc" do
    observer = React::Observable.new(:current_value) { |new_value| new_value}
    observer.to_proc.call(:new_value)
    expect(observer.to_proc.call).to eq(:current_value)
  end
  
  it "will forward any other messages to its current value, and then call the block with the result of the message" do
    tested = false
    observer = React::Observable.new([]) { |new_value| expect(new_value).to eq([:added_a_value]); tested = true}
    observer << :added_a_value
    expect(tested).to be_truthy
  end
  
end
  
  
