require 'nokogiri'
require 'staging-compute/networks'

class NetworksController
  def self.list
    JSON.generate(Networks.list)
  end

  def self.get(name)
    network = Networks.find(name)
    return 404 unless network
    JSON.generate(network)
  end

  def self.create(name, params)
    # Return if conflicting resource
    return 409 if Networks.find(name)

    # Sadly this has to be generated as an XML file
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.network do
        xml.name(name)
        xml.forward(mode: 'bridge')
        xml.bridge(name: params['bridge'])
        xml.virtualport(type: 'openvswitch')
        xml.vlan do
          xml.tag(id: params['vlan'])
        end
      end
    end

    # Ensure the file is flushed to disk
    File.open('/tmp/network.xml', 'w') do |temp|
      temp.write(builder.to_xml)
    end

    # Create the network
    return 500 unless system('virsh net-create /tmp/network.xml')

    # Indicate the resource has been created
    200
  end

  def self.delete(name)
    # Return if no resource exists
    return 404 unless Networks.find(name)

    # Delete the network
    return 500 unless system("virsh net-destroy #{name}")

    # Indicate the resource was deleted
    200
  end
end
