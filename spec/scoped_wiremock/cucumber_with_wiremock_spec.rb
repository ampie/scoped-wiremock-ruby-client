require 'cucumber/cli/main'
require_relative '../../lib/scoped_wiremock/cucumber/cucumber_with_wiremock'
describe 'When using Cucumber with WireMock' do
  before :each do
    parent_dir=File.dirname(__FILE__)
    conf = Cucumber::Cli::Configuration.new
    conf.parse! [File.join(parent_dir, 'cucumber', 'features'), '--format=ScopedWireMock::CucumberWithWireMock', '--out=tmp.json', '--format=pretty', '-r',
                 File.join(parent_dir, 'cucumber', 'features', 'step_definitions')]
    @runtime = Cucumber::Runtime.new (conf)
  end
  it 'should manage the scopes correctly' do
    @runtime.run!
  end

end
