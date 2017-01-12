require 'json'
require 'staging-hypervisor-agent/hosts'

class HostsController
  def self.list
    JSON.generate(Hosts.list)
  end

  def self.get(name)
    return 404 unless Hosts.get(name)
    JSON.generate(Hosts.get(name))
  end

  def self.create(name, params)
    return 409 if Hosts.get(name)
    return 400 unless params['install']
    return 500 unless Hosts.create(name, params)
    201
  end

  def self.delete(name)
    return 404 unless Hosts.get(name)
    return 500 unless Hosts.delete(name)
    204
  end

  def self.start(name)
    return 404 unless Hosts.get(name)
    return 500 unless Hosts.start(name)
    204
  end
end
