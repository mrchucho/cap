require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Alerts, "index action" do
  before(:each) do
    dispatch_to(Alerts, :index)
  end
end