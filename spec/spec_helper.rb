$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'lstash'

RSpec.configure do |config|
  config.order = 'random'
end