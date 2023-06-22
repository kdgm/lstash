$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "lstash"

require "rspec/its"

require "timecop"

ENV["ES_URL"] = nil
ENV["TZ"] = "Europe/Amsterdam" # Test in a specific timezone.

RSpec.configure do |config|
  config.order = "random"
end

require "stringio"

def capture_stdout
  old = $stdout
  $stdout = fake = StringIO.new
  yield
  fake.string
ensure
  $stdout = old
end

def capture_stderr
  old = $stderr
  $stderr = fake = StringIO.new
  yield
  fake.string
ensure
  $stderr = old
end
