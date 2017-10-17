require 'docker'

class Kontena::Plugin::Local::RemoveCommand < Kontena::Command
  include Kontena::Cli::Common

  option "--force", :flag, "Force remove", default: false, attribute_name: :forced

  def execute
    confirm_command('local-kontena') unless forced?

    remove_container('kontena-master-api')
    remove_container('kontena-master-mongo')
    remove_container('kontena-agent')
    remove_container('kontena-ipam-plugin')
    remove_container('kontena-etcd')
    remove_container('kontena-etcd-data')
    remove_container('kontena-cadvisor')
    remove_container('weave')
    remove_container('kontena-registry')

    remove_volume('kontena-master-db')

    Kontena.run('master rm --force --silent local-kontena')
  end

  def remove_container(name)
    container = Docker::Container.get(name) rescue nil
    if container
      spinner "Removing #{name}" do
        container.delete(force: true)
      end
    end
  end

  def remove_volume(name)
    volume = Docker::Volume.get(name) rescue nil
    if volume
      spinner "Removing volume #{name}" do
        volume.remove
      end
    end
  end
end
