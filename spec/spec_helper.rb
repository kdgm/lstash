$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'lstash'

require 'rspec/its'

RSpec.configure do |config|
  config.order = 'random'
end