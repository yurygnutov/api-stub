require_relative 'spec_helper'

describe 'MockService' do

  before(:all) do
    start_app
  end

  after(:all) do
    stop_app
  end

  describe 'set up for POST test response to save history' do
    let :setup do
      [
        {
          'method' => 'POST',
          'path' => '/test',
          'response_body' => 'TEST'
        }
      ]
    end

    before do
      send_get('localhost', 8080, '/__drop_history')
      send_post('localhost', 8080, '/__setup', setup)
      send_post('localhost', 8080, '/test')
    end

    it 'and responds with history when requested' do
      expect(JSON.parse(send_post('localhost', 8080, '/__check', setup[0]).response.body)['reply']['body']).to eq('TEST')
    end
  end

  describe 'set up for few responses for different methods to save history' do
    let :setup do
      [
        {
          'method' => 'POST',
          'path' => '/testPOST',
          'response_body' => 'TESTpost'
        }, {
          'method' => 'PUT',
          'path' => '/testPUT',
          'response_body' => 'TESTput'
        }
      ]
    end

    before do
      send_get('localhost', 8080, '/__drop_history')
      send_post('localhost', 8080, '/__setup', setup)
      send_post('localhost', 8080, '/testPOST')
      send_put('localhost', 8080, '/testPUT')
    end

    it 'and responds with history of first reply when requested' do
      expect(JSON.parse(send_post('localhost', 8080, '/__check', setup[0]).response.body)['reply']['body']).to eq('TESTpost')
    end

    it 'and responds with history of second reply when requested' do
      expect(JSON.parse(send_post('localhost', 8080, '/__check', setup[1]).response.body)['reply']['body']).to eq('TESTput')
    end
  end

  describe 'set up for few responses for different paths to save history' do
    let :setup do
      [
        {
          'method' => 'POST',
          'path' => '/test1',
          'response_body' => 'TEST1'
        }, {
          'method' => 'POST',
          'path' => '/test2',
          'response_body' => 'TEST2'
        }
      ]
    end

    before do
      send_get('localhost', 8080, '/__drop_history')
      send_post('localhost', 8080, '/__setup', setup)
      send_post('localhost', 8080, '/test1')
      send_post('localhost', 8080, '/test2')
    end

    it 'and responds with history of first reply when requested' do
      expect(JSON.parse(send_post('localhost', 8080, '/__check', setup[0]).response.body)['reply']['body']).to eq('TEST1')
    end

    it 'and responds with history of second reply when requested' do
      expect(JSON.parse(send_post('localhost', 8080, '/__check', setup[1]).response.body)['reply']['body']).to eq('TEST2')
    end
  end

  describe 'set up for POST test response to save history with code' do
    let :setup do
      [
        {
          'method' => 'POST',
          'path' => '/test',
          'response_body' => 'TEST',
          'code' => 301
        }
      ]
    end

    before do
      send_get('localhost', 8080, '/__drop_history')
      send_post('localhost', 8080, '/__setup', setup)
      send_post('localhost', 8080, '/test')
    end

    it 'and responds with history when requested' do
      expect(JSON.parse(send_post('localhost', 8080, '/__check', setup[0]).response.body)['reply']['code']).to eq(301)
    end
  end

  describe 'has old set ups and new set up and check reply on new setup' do
    let :oldsetup do
      [
        {
          'method' => 'POST',
          'path' => '/old-setup-url',
          'response_body' => "{\"status\":\"success\"}"
        }
      ]
    end
    let :setup do
      [
        {
          'method' => 'POST',
          'path' => '/test1',
          'response_body' => 'TEST1'
        }, {
          'method' => 'POST',
          'path' => '/test2',
          'response_body' => 'TEST2'
        }
      ]
    end

    before do
      send_post('localhost', 8080, '/__setup', oldsetup)
      send_post('localhost', 8080, '/__setup', setup)

      send_post('localhost', 8080, '/test1')
      send_post('localhost', 8080, '/test2')
      send_post('localhost', 8080, '/__check', setup[0])
    end

    it 'and responds correctly with oldsetup' do
      expect(send_post('localhost', 8080, '/old-setup-url').response.body).to eq("{\"status\":\"success\"}")
    end
  end

  describe 'set up for POST test request to save history' do
    let :setup do
      [
        {
          'method' => 'POST',
          'path' => '/test',
          'request_body' => 'sample'
        }
      ]
    end
    let :request do
      [
        'testme'
      ]
    end

    before do
      send_get('localhost', 8080, '/__drop_history')
      send_post('localhost', 8080, '/__setup', setup)
      send_post('localhost', 8080, '/test',request)
    end

    it 'and the request body obtained from history is correct' do
      expect(JSON.parse(send_post('localhost', 8080, '/__check', setup[0]).response.body)['request']['body']).to eq(request.to_s)
    end
  end
end