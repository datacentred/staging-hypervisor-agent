require 'json'
require 'staging-compute/hosts'

class HostsController
  def self.list
    JSON.generate(Hosts.list)
  end

  def self.get(name)
    return 404 unless Hosts.find(name)
    JSON.generate(Hosts.find(name))
  end

  def self.create(name, params)
    return 409 if Hosts.find(name)
    return 400 unless params['install']
    return 500 unless Hosts.create(name, params)
    201
  end

  def self.delete(name)
    return 404 unless Hosts.find(name)
    return 500 unless Hosts.delete(name)
    204
  end
end
