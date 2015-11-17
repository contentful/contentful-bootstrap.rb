$LOAD_PATH.unshift File.expand_path('lib', __FILE__)

require 'contentful/bootstrap'
require 'vcr'
require 'json'

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_fixtures"
  config.hook_into :webmock
end

def json_fixture(name)
  json = JSON.load(File.read("spec/fixtures/json_fixtures/#{name}.json"))
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

class SpaceDouble
  def id
    'foobar'
  end

  def name
    'foobar'
  end
end

class ServerDouble
  def [](key)
  end
end

class RequestDouble
  attr_accessor :query
end

class ResponseDouble
  attr_accessor :body, :status, :content_type
end
