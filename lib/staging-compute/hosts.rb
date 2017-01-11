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

  def self.create(name, params)
    command = [
      'virt-install',
      "--name #{name}",
      "--ram #{params['memory']}",
      '--controller type=scsi,model=virtio-scsi',
    ]

    command += params['disks'].map.with_index do |size, index|
      "--disk path=/var/lib/staging-compute/#{name}.#{index}.img,size=#{size},bus=scsi"
    end

    command += params['networks'].map do |network|
      "--network network=#{network}"
    end

    command << "--location #{params['location']}" if params['location']
    command << "--extra-args '#{params['cmdline']}'" if params['cmdline']

    system(command.join(' '))
  end

  def self.delete(name)
    return false unless system("virsh destroy #{name}")
    return false unless system("virsh undefine #{name}")

    disks = Dir.glob("/var/lib/staging-compute/#{name}.*")
    File.delete(*disks)
  end

end
