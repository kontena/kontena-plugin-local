require 'docker'

class Kontena::Plugin::Local::UpCommand < Kontena::Command
  include Kontena::Cli::Common

  option "--version", "VERSION", "Define installed Kontena version", default: 'latest'

  def execute
    ensure_mongodb
    ensure_master
    wait_master_response
    login_to_master
    create_grid
    ensure_registry

    puts ""
    puts ""
    puts "  Kontena Platform Master: #{Kontena.pastel.green.on_black('http://localhost:8181')}"
    puts "  Kontena Image Registry: #{Kontena.pastel.green.on_black('http://localhost:5000')}"
    puts ""
    puts "  Kontena CLI is configured to use local installation, have fun!!!"
  end

  def ensure_mongodb
    mongodb = Docker::Container.get('kontena-master-mongo') rescue nil
    return if mongodb
    ensure_image('mongo:3.2')

    spinner "Creating #{pastel.cyan('database')} container" do
      mongodb = Docker::Container.create(
        'name' => 'kontena-master-mongo',
        'Image' => 'mongo:3.2',
        'Volumes' => {
          '/data/db' => {}
        },
        'HostConfig' => {
          'Binds' => ['kontena-master-db:/data/db'],
          'RestartPolicy' => {'Name' => 'unless-stopped'}
        }
      )
      mongodb.start
    end
  end

  def ensure_master
    master = Docker::Container.get('kontena-master-api') rescue nil
    abort('master already exists') if master
    image = "kontena/server:#{version}"
    ensure_image(image)
    spinner "Creating #{pastel.cyan('master')}" do
      master = Docker::Container.create(
        'name' => 'kontena-master-api',
        'Image' => image,
        'Env' => [
          'MONGODB_URI=mongodb://mongodb:27017/kontena_server',
          "VAULT_KEY=#{SecureRandom.hex(24)}",
          "VAULT_IV=#{SecureRandom.hex(24)}",
          "INITIAL_ADMIN_CODE=initialadmincode",
          "CONTAINER_LOGS_CAPPED_SIZE=128",
          "CONTAINER_STATS_CAPPED_SIZE=64",
          "EVENT_LOGS_CAPPED_SIZE=32",
          "WEB_CONCURRENCY=1"
        ],
        'ExposedPorts' => {
          '9292/tcp' => {}
        },
        'HostConfig' => {
          'Links' => ['kontena-master-mongo:mongodb'],
          'PortBindings' => {
            '9292/tcp': [
              {'HostPort' => '8181'}
            ]
          },
          'RestartPolicy' => {'Name' => 'unless-stopped'}
        }
      )
      master.start
    end
  end

  def wait_master_response
    spinner "Waiting for #{pastel.cyan('master')} to start" do
      begin
        while Excon.get('http://localhost:8181').status != 200
          sleep 2
        end
      rescue
        sleep 1
        retry
      end
    end
  end

  def login_to_master
    spinner "Logging in to #{pastel.cyan('master')}"
    Kontena.run!([
      'master', 'login', '--name', 'local-kontena',
      '--code', 'initialadmincode', '--silent',
      'http://localhost:8181'
    ])
  end

  def create_grid
    token = SecureRandom.hex(16)
    Kontena.run!([
      'grid', 'create', '--token', token,
      '--silent', 'local-kontena'
    ])

    image = "kontena/agent:#{version}"
    ensure_image(image)
    agent = nil
    spinner "Creating #{pastel.cyan('agent')}" do
      agent = Docker::Container.create(
        'name' => 'kontena-agent',
        'Image' => image,
        'Env' => [
          "KONTENA_URI=http://localhost:8181",
          "KONTENA_TOKEN=#{token}",
          "CADVISOR_IMAGE=google/cadvisor",
          "CADVISOR_VERSION=v0.26.1"
        ],
        'Volumes' => {
          '/var/run/docker.sock' => {}
        },
        'HostConfig' => {
          'Binds' => ['/var/run/docker.sock:/var/run/docker.sock'],
          'NetworkMode' => 'host',
          'RestartPolicy' => { 'Name' => 'unless-stopped' }
        }
      )
      agent.start!
    end
  end

  def ensure_registry
    registry = Docker::Container.get('kontena-registry') rescue nil
    return if registry

    image = "kontena/registry:2.6.2"
    ensure_image(image)
    spinner "Creating #{pastel.cyan('registry')}" do
      registry = Docker::Container.create(
        'name' => 'kontena-registry',
        'Image' => image,
        'ExposedPorts' => {
          '5000/tcp' => {}
        },
        'HostConfig' => {
          'PortBindings' => {
            '5000/tcp': [
              {'HostPort' => '5000'}
            ]
          },
          'RestartPolicy' => {'Name' => 'unless-stopped'}
        }
      )
      registry.start
    end
  end

  def ensure_image(image)
    spinner "Pulling container image #{pastel.cyan(image)}" do
      Docker::Image.create('fromImage' => image)
    end
  end
end
