require 'docker'

class Kontena::Plugin::Local::RemoveCommand < Kontena::Command
  include Kontena::Cli::Common

  option "--force", :flag, "Force remove", default: false, attribute_name: :forced

  def execute
    confirm_command('local-kontena') unless forced?

    remove_stacks
    remove_services
    remove_volumes
    wait_for_remove_complete

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

  def wait_for_remove_complete
    spinner "Waiting for removals to complete" do
      sleep 5
    end
  end

  def remove_stacks
    spinner "Removing stacks" do
      client.get("grids/local-kontena/stacks")['stacks'].each do |stack|
        client.delete("stacks/#{stack['id']}")
      end
    end
  end

  def remove_services
    spinner "Removing services" do
      client.get("grids/local-kontena/services")['services'].each do |service|
        client.delete("services/#{service['id']}")
      end
    end
  end

  def remove_volumes
    spinner "Removing volumes" do
      client.get("volumes/local-kontena")['volumes'].each do |volume|
        client.delete("volumes/#{volume['id']}")
      end
    end
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
