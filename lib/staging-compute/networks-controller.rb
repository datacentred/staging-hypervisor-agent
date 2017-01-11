require 'nokogiri'
require 'staging-compute/networks'

class NetworksController
  def self.list
    JSON.generate(Networks.list)
  end

  def self.get(name)
    return 404 unless Networks.find(name)
    JSON.generate(Networks.find(name))
  end

  def self.create(name, params)
    return 409 if Networks.find(name)
    return 500 unless Networks.create(name, params)
    201
  end

  def self.delete(name)
    return 404 unless Networks.find(name)
    return 500 unless Networks.delete(name)
    204
  end
end
