require_relative 'spec_helper'

describe 'MockService' do

  before(:all) do
    start_app
  end

  after(:all) do
    stop_app
  end

  describe 'set up for POST test response' do
    before do
      setup = [
        {
          'method' => 'POST',
          'path' => '/test',
          'response_body' => 'TEST',
          'code' => 301
        }
      ]

      send_post('localhost', 8080, '/__setup', setup)
    end

    it 'responds with POST test response when requested' do
      expect(send_post('localhost', 8080, '/test', {test: 'body'}).response.code).to eq('301')
    end
  end
end