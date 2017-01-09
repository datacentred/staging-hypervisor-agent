require 'nokogiri'

class Networks
  def self.networks
    input = `virsh net-list`.split("\n").drop(2)
    input.map do |line|
      Hash[[:name, :state, :autostart, :persistent].zip(line.split)]
    end
  end

  def self.find(name)
    networks.find{|network| network[:name] == name}
  end

  def self.create(name, bridge, vlan)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.network do
        xml.name(name)
        xml.forward(mode: 'bridge')
        xml.bridge(name: bridge)
        xml.virtualport(type: 'openvswitch')
        xml.vlan do
          xml.tag(id: vlan)
        end
      end
    end

    File.open('/tmp/network.xml', 'w') do |temp|
      temp.write(builder.to_xml)
    end

    system('virsh net-create /tmp/network.xml')
  end
end
