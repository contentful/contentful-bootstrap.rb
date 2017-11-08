require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('lib', __FILE__)

require 'contentful/bootstrap'
require 'vcr'
require 'json'

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end

VCR.configure do |config|
  config.cassette_library_dir = File.join('spec', 'fixtures', 'vcr_fixtures')
  config.hook_into :webmock
end

def json_path(name)
  File.join('spec', 'fixtures', 'json_fixtures', "#{name}.json")
end

def json_fixture(name)
  json = JSON.load(File.read(File.expand_path(json_path(name))))
  yield json if block_given?
  json
end

def vcr(cassette)
  VCR.use_cassette(cassette) do
    yield if block_given?
  end
end

def ini(ini_file)
  file = IniFile.load(ini_file)
  yield file if block_given?
  file
end

class ApiKeyDouble
  attr_reader :name, :description, :access_token

  def initialize(name, description)
    @name = name
    @description = description
    @access_token = 'random_api_key'
  end
end

class ApiKeysHandlerDouble
  def create(options)
    ApiKeyDouble.new(options[:name], options[:description])
  end
end

class SpaceDouble
  def id
    'foobar'
  end

  def name
    'foobar'
  end

  def api_keys
    ApiKeysHandlerDouble.new
  end
end

class ServerDouble
  def [](key)
  end
end

class ErrorRequestDouble
  def request; self; end
  def endpoint; self; end
  def error_message; self; end
  def raw; self; end
  def body; self; end
  def status; self; end
end

class RequestDouble
  attr_accessor :query
end

class ResponseDouble
  attr_accessor :body, :status, :content_type
end
