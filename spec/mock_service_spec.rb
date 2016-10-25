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
          'response_body' => 'TEST'
        }
      ]

      send_post('localhost', 8080, '/__setup', setup)
    end

    it 'responds with POST test response when requested' do
      expect(send_post('localhost', 8080, '/test', {test: 'body'}).response.body).to eq('TEST')
    end
  end

  describe 'set up for simple JSON POST test response' do
    before do
      setup = [
        {
          'method' => 'POST',
          'path' => '/test',
          'response_body' => {respond: 'TEST'}
        }
      ]

      send_post('localhost', 8080, '/__setup', setup)
    end

    it 'responds with POST test response when requested' do
      expect(send_post('localhost', 8080, '/test', {test: 'body'}).response.body).to eq({respond: 'TEST'}.to_json)
    end
  end

  describe 'set up for PUT test response' do
    before do
      setup = [
        {
          'method' => 'PUT',
          'path' => '/test',
          'response_body' => 'TEST'
        }
      ]

      send_post('localhost', 8080, '/__setup', setup)
    end

    it 'responds with PUT test response when requested' do
      expect(send_put('localhost', 8080, '/test').response.body).to eq('TEST')
    end
  end

  describe 'set up two different method paths' do
    before do
      setup = [
        {
          'method' => 'PUT',
          'path' => '/testPUT',
          'response_body' => 'TEST'
        }
      ]

      send_post('localhost', 8080, '/__setup', setup)

      setup = [
        {
          'method' => 'POST',
          'path' => '/testPOST',
          'response_body' => 'TEST'
        }
      ]

      send_post('localhost', 8080, '/__setup', setup)
    end

    it 'responds with correct response when requested by first path' do
      expect(send_put('localhost', 8080, '/testPUT').response.body).to eq('TEST')
    end

    it 'responds with correct response when requested by second path' do
      expect(send_post('localhost', 8080, '/testPOST').response.body).to eq('TEST')
    end
  end

  describe 'set up two different method paths in single call' do
    before do
      setup = [
        {
          'method' => 'PUT',
          'path' => '/testPUT',
          'response_body' => 'TEST'
        }, {
          'method' => 'POST',
          'path' => '/testPOST',
          'response_body' => 'TEST'
        }
      ]

      send_post('localhost', 8080, '/__setup', setup)
    end

    it 'responds with correct response when requested by first path' do
      expect(send_put('localhost', 8080, '/testPUT').response.body).to eq('TEST')
    end

    it 'responds with correct response when requested by second path' do
      expect(send_post('localhost', 8080, '/testPOST').response.body).to eq('TEST')
    end
  end

  describe 'set up two same type method paths' do
    before do
      setup = [
        {
          'method' => 'POST',
          'path' => '/test1',
          'response_body' => 'TEST'
        }
      ]

      send_post('localhost', 8080, '/__setup', setup)

      setup = [
        {
          'method' => 'POST',
          'path' => '/test2',
          'response_body' => 'TEST'
        }
      ]

      send_post('localhost', 8080, '/__setup', setup)
    end

    it 'responds with correct response when requested by first path' do
      expect(send_post('localhost', 8080, '/test1').response.body).to eq('TEST')
    end

    it 'responds with correct response when requested by second path' do
      expect(send_post('localhost', 8080, '/test2').response.body).to eq('TEST')
    end
  end

  describe 'set up for nothing' do
    it 'and on POST responds with 404' do
      expect(send_post('localhost', 8080, '/not_configured').response.code).to eq('404')
    end

    it 'and on PUT responds with 404' do
      expect(send_put('localhost', 8080, '/not_configured').response.code).to eq('404')
    end

    it 'and on GET responds with 404' do
      expect(send_get('localhost', 8080, '/not_configured').response.code).to eq('404')
    end
  end
end