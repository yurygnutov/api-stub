# Test framework
require 'rspec'
require 'rack'
require_relative '../lib/mock_service'
require 'pry'
require 'yaml'

def send_post(host, port, path, payload = nil)
  request= Net::HTTP::Post.new(path)
  request.body = JSON.generate(payload) unless payload.nil?
  send_request(host, port, request)
end

def send_get(host, port, path)
  request= Net::HTTP::Get.new(path)
  send_request(host, port, request)
end

def send_put(host, port, path, payload = nil)
  request= Net::HTTP::Put.new(path)
  request.body = JSON.generate(payload) unless payload.nil?
  send_request(host, port, request)
end

def send_request(host, port, request)
  http = Net::HTTP.start(host, port)
  http.request(request)
end

def start_app
  @mock_thread = Thread.new {
    Rack::Handler::WEBrick.run(
      MockService,
      Port: 8080,
      Logger: WEBrick::Log::new($stderr, WEBrick::Log::ERROR
      ), AccessLog: [])
  }
  sleep(2)
end

def stop_app
  @mock_thread.kill
end