class Hosts
  def self.list
    input = `virsh list --all`.split("\n").drop(2)
    input.map do |line|
      Hash[[:id, :name, :state].zip(line.split)]
    end 
  end

  def self.find(name)
    list.find{|host| host[:name] == name}
  end
end
