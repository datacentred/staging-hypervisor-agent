require 'json'
require 'sinatra/base'
require 'staging-hypervisor-agent/hosts-controller'
require 'staging-hypervisor-agent/networks-controller'

class Server < Sinatra::Base
  set :bind, '0.0.0.0'
  set :port, 8420

  before do
    if request.request_method == 'POST'
      begin
        @body = JSON.parse(request.body.read)
      rescue JSON::ParserError
        halt 500
      end
    end
  end

  get '/hosts' do
    HostsController.list
  end

  get '/hosts/:host' do
    HostsController.get(params['host'])
  end

  post '/hosts/:host' do
    HostsController.create(params['host'], @body)
  end

  delete '/hosts/:host' do
    HostsController.delete(params['host'])
  end

  put '/hosts/:host/start' do
    HostsController.start(params['host'])
  end

  get '/networks' do
    NetworksController.list
  end

  get '/networks/:network' do
    NetworksController.get(params['network'])
  end

  post '/networks/:network' do
    NetworksController.create(params['network'], @body)
  end

  delete '/networks/:network' do
    NetworksController.delete(params['network'])
  end
end
