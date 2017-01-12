class Hosts
  def self.list
    input = `virsh list --all`.split("\n").drop(2)
    input.map do |line|
      Hash[[:id, :name, :state].zip(line.split($;, 3))]
    end 
  end

  def self.get(name)
    list.find{|host| host[:name] == name}
  end

  def self.create(name, params)
    command = [
      'virt-install',
      "--name #{name}",
      "--ram #{params['memory']}",
      '--controller type=scsi,model=virtio-scsi',
      '--noautoconsole',
    ]

    command += params['disks'].map.with_index do |size, index|
      "--disk path=/var/lib/staging-hypervisor-agent/#{name}.#{index}.img,size=#{size},bus=scsi"
    end

    command += params['networks'].map do |network|
      "--network network=#{network}"
    end

    command << "--location #{params['location']}" if params['location']
    command << "--extra-args '#{params['cmdline']}'" if params['cmdline']

    system(command.join(' '))
  end

  def self.delete(name)
    unless get(name)[:state] == 'shut off'
      return false unless system("virsh destroy #{name}")
    end
    return false unless system("virsh undefine #{name}")

    disks = Dir.glob("/var/lib/staging-hypervisor-agent/#{name}.*")
    File.delete(*disks)
  end

  def self.start(name)
    system("virsh start #{name}")
  end
end
