require 'minitest/spec'

module MinitestWorld
  extend Minitest::Assertions
  mattr_accessor :assertions
  self.assertions = 0
end

World(MinitestWorld)
