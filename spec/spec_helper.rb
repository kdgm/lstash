$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "lstash"

require "rspec/its"

require "timecop"

ENV["ES_URL"] = nil
ENV["TZ"] = "Europe/Amsterdam" # Test in a specific timezone.

RSpec.configure do |config|
  config.order = "random"

  # Suggestions taken from http://railscasts.com/episodes/413-fast-tests
  #
  # Focus on specific specs by tagging with `:focus`
  # or use `fit` instead of `it`.
  # ```ruby
  # it "focus test", :focus do
  # end
  #
  # fit "focus test" do
  # end
  # ```
  config.alias_example_to :fit, focus: true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
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
