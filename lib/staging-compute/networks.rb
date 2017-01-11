class Networks
  def self.list
    input = `virsh net-list`.split("\n").drop(2)
    input.map do |line|
      Hash[[:name, :state, :autostart, :persistent].zip(line.split)]
    end
  end

  def self.find(name)
    list.find{|network| network[:name] == name}
  end

  def self.create(name, params)
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

    File.open('/tmp/network.xml', 'w') do |temp|
      temp.write(builder.to_xml)
    end

    system('virsh net-create /tmp/network.xml')
  end

  def self.delete(name)
    system("virsh net-destroy #{name}")
  end
end
