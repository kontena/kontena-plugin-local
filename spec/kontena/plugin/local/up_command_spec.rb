require 'kontena/plugin/local/up_command'

describe Kontena::Plugin::Local::UpCommand do
  let(:subject) do
    described_class.new(File.basename($0))
  end

  describe '#run' do
    it 'calls docker' do
      VCR.use_cassette("up") do
        expect {
          subject.run([])
        }.to output(/have fun/).to_stdout
      end
    end
  end
end