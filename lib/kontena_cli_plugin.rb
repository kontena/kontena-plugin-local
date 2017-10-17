require 'kontena_cli'
require_relative 'kontena/plugin/local'
require_relative 'kontena/plugin/local_command'

Kontena::MainCommand.register("local", "Manage local Kontena Platform, optimized for development workflows", Kontena::Plugin::LocalCommand)
