require "pry"
require 'sinatra/base'
require 'json'
require 'mongo'

class MockService < Sinatra::Base
  configure :production, :development do
    config = {}
    config[:db] = File.open(File.join('config', 'persistence.yml')) { |f| YAML.load_file(f) if config == {} }
    local_file_path = File.join('config', 'persistence.local.yml')
    config[:db].merge!(File.open(local_file_path) { |f| YAML.load_file(f) } ) if File.exist?(local_file_path)

    set :database_connection, config[:db][:connect]
    set :database_port, config[:db][:port]
    set :database_name, config[:db][:database]
  end

  # enable :logging
  disable :logging

  def self.db_connection 
    @@db_connection ||= begin 
      Mongo::Logger.logger.level = ::Logger::FATAL

      db = Mongo::Client.new(
        [[settings.database_connection, settings.database_port].join(':')],
        database: settings.database_name
      )
      db[:setup].drop
      db[:reply].drop
      db[:request].drop
      db
    end 
  end

  def db_connection
    self.class.db_connection 
  end

  before do
    @request_body = request.body.read
    puts "IN [path]: #{request.path}"
    puts "IN [params]: #{params}"
    puts "IN [body]: #{@request_body}"

    #save the request in mongo_db
    db_connection[:request].insert_one(
      {
          :body => @request_body,
          :path => request.path,
          :method => request.env['REQUEST_METHOD']

      }
    )
  end

  after do
    puts "OUT [code]: #{response.status}; OUT [body]: #{response.body}\n"
  end

  # Receives array of endpoints to mock, like:
  #   [{
  #     method: "POST",
  #     path: "/balance",
  #     response_body: "12345",
  #   }, {
  #     ...
  #   }]
  post '/__setup' do
    JSON.parse(@request_body).each do |mock|
      mock.merge!({'code' => 200}) unless mock['code']
      db_connection[:setup].insert_one(mock)
    end
    'roger that'
  end

  # Returns the mocks with their recorded replies,
  # which are set to save in history;
  # request like:
  # {
  #   method: "POST",
  #   path: "/balance",
  # }
  post '/__check' do
    tc = JSON.parse(@request_body)
    reply = db_connection[:reply].find({method: tc['method'], path: tc['path']}).to_a.last
    request = db_connection[:request].find({method: tc['method'], path: tc['path']}).to_a.last
    reply.delete('_id')
    request.delete('_id')
    {"reply" => reply, "request" => request}.to_json
  end

  get '/__drop_history' do
    db_connection[:setup].drop
    db_connection[:reply].drop
    db_connection[:request].drop
    'roger that'
  end

  # Mock paths
  get '*' do
    call_mock 'GET'
  end

  put '*' do
    call_mock 'PUT'
  end

  post '*' do
    call_mock 'POST'
  end

  delete '*' do
    call_mock 'DELETE'
  end

  def call_mock(method)

    mock = db_connection[:setup].find('method' => method, "path" => request.path).to_a.last

    if mock
      # save reply to history
      db_connection[:reply].insert_one(
        {
          :body => mock['response_body'],
          :path => mock['path'],
          :method => mock['method'],
          :code => mock['code']
        }
      )

      respond = mock['response_body']

      # clean set up after call
      db_connection[:setup].delete_one('method' => method, "path" => request.path)
      status mock['code']
      respond.respond_to?(:keys) ? respond.to_json : respond
    else
      halt 404
    end
  end
end
