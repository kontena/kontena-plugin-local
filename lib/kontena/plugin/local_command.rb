class Kontena::Plugin::LocalCommand < Kontena::Command

  subcommand ['start', 'up'], 'Start local Kontena Platform', load_subcommand('kontena/plugin/local/up_command')
  subcommand ['remove', 'rm'], 'Remove local Kontena Platform', load_subcommand('kontena/plugin/local/remove_command')

  def execute
  end
end
