require 'spec_helper'

describe Contentful::Bootstrap::Management do
  it ':user_agent' do
    expect(subject.user_agent).to eq('User-Agent' => "ContentfulBootstrap/#{Contentful::Bootstrap::VERSION}")
  end

  it ':request_headers' do
    expect(subject.request_headers).to include('User-Agent' => "ContentfulBootstrap/#{Contentful::Bootstrap::VERSION}")
  end
end
