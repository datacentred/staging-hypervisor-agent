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
end
