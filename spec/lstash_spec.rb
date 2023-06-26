require "spec_helper"
require "lstash/cli"

describe Lstash do
  it "should have a version number" do
    expect(Lstash::VERSION).not_to be nil
  end
end
