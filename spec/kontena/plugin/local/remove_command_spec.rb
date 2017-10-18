require 'kontena/plugin/local/remove_command'

describe Kontena::Plugin::Local::RemoveCommand do
  let(:subject) do
    described_class.new(File.basename($0))
  end

  describe '#run' do
    it 'calls docker' do
      VCR.use_cassette("remove") do
        expect {
          subject.run(['--force'])
        }.to output(/removing kontena-master-api/).to_stdout
      end
    end
  end
end