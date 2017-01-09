require 'json'
require 'sinatra/base'
require 'staging-compute/hosts'
require 'staging-compute/networks'

class StagingCompute < Sinatra::Base
  get '/hosts' do
    JSON.generate(Hosts.hosts)
  end

  get '/hosts/:host' do
    host = Hosts.find(params['host'])
    return 404 unless host
    JSON.generate(host)
  end

  get '/hosts/:host/networks/:network' do
    name = Hosts.network_name(params['host'], params['network'])
    network = Networks.find(name)
    return 404 unless network
    JSON.generate(network)
  end

  post '/hosts/:host/networks/:network' do
    name = Hosts.network_name(params['host'], params['network'])
    begin
      body = JSON.parse(request.body.read)
    rescue JSON::ParserError
      return 400
    end
    return 400 unless ['bridge', 'vlan'].all?{|p| body.include?(p)}
    return 409 if Networks.find(name)
    return 500 unless Networks.create(name, body['bridge'], body['vlan'])
    201
  end
end
