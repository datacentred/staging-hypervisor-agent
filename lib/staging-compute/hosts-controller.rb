require 'json'
require 'staging-compute/hosts'

class HostsController
  def self.list
    JSON.generate(Hosts.list)
  end

  def self.get(name)
    host = Hosts.find(name)
    return 404 unless host
    JSON.generate(host)
  end

  def self.create(name, params)
    # Return if conflicting resource
    return 409 if Hosts.find(name)

    # Non-install builds currently unsupported
    return 400 unless params['install']

    # Common command parameters
    command = [
      'virt-install',
      "--name #{name}",
      "--ram #{params['memory']}",
      '--controller type=scsi,model=virtio-scsi',
    ]

    # Add in required disks and networks
    command += params['disks'].map.with_index do |size, index|
      "--disk path=/var/lib/staging-compute/#{name}.#{index}.img,size=#{size},bus=scsi"
    end

    command += params['networks'].map do |network|
      "--network network=#{network}"
    end

    # Add optional arguments
    command << "--location #{params['location']}" if params['location']
    command << "--extra-args '#{params['cmdline']}'" if params['cmdline']
    command << '--noautoconsole' unless params['console']

    puts command.join(' ')
    # Create the host
    return 500 unless system(command.join(' '))

    # Indicate the resource has been created
    200
  end

  def self.delete(name)
    # Return if no resource exists
    return 404 unless Hosts.find(name)

    # Delete the host
    return 500 unless system("virsh destroy #{name}")
    return 500 unless system("virsh undefine #{name}")

    # Delete all associated disks
    disks = Dir.glob("/var/lib/staging-compute/#{name}.*")
    File.delete(*disks)

    # Indicate the resource has been deleted
    200
  end
end
