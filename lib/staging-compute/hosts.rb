class Hosts
  def self.network_name(host, network)
    host + ':' + network
  end

  def self.hosts
    input = `virsh list --all`.split("\n").drop(2)
    input.map do |line|
      Hash[[:id, :name, :state].zip(line.split)]
    end 
  end

  def self.find(name)
    hosts.find{|host| host[:name] == name}
  end
end
