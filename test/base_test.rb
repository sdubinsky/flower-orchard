require 'minitest/autorun'
require 'rack/test'
require 'sequel'
require 'sqlite3'
require 'logger'
require 'pry'

class BaseTest < MiniTest::Test
  DB = Sequel.sqlite
end
