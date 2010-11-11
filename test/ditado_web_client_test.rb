require File.expand_path(File.dirname(__FILE__) + '/ditado_test_helper')

describe Ditado::Core, 'when using UI' do
  
  include Rack::Test::Methods

  def app
    Ditado::WebClient
  end
  
  before(:all) do
    setup_environment
    @ditado = Ditado::Core.new DITADO_TEST_ENVIRONMENT
    @ditado.init
  end
  
  it 'starts the web client when receive the ui start command' do
    get '/'
    last_response.should be_ok
  end
  
  after(:all) do
    teardown_environment
  end
end