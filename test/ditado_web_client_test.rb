require File.expand_path(File.dirname(__FILE__) + '/ditado_test_helper')

describe Ditado::Core, 'when using UI' do
  
  include Rack::Test::Methods

  def app
    Ditado::WebClient
  end
  
  before(:each) do
    setup_environment
    @ditado = Ditado::Core.init DITADO_TEST_ENVIRONMENT
  end
  
  it 'should provide a index page' do
    get '/'
    last_response.should be_ok
    last_response.body.should == 'Hello World!'
  end
  
  it 'should have a issues page' do
    get '/issues'
    last_response.should be_ok
    last_response.body.should == 'Issues:'
  end
  
  it 'should have a page for each issue' do
    issue_id_1 = @ditado.issue_add ISSUE_CONTENT_1
    issue_id_2 = @ditado.issue_add ISSUE_CONTENT_2
    
    get "/issues/#{issue_id_1}"
    last_response.should be_ok
    last_response.body.should == ISSUE_CONTENT_1

    get "/issues/#{issue_id_2}"
    last_response.should be_ok
    last_response.body.should == ISSUE_CONTENT_2
  end
  
  it 'should be able to remove a issue' do
    issue_id_1 = @ditado.issue_add ISSUE_CONTENT_1
    
    get "/issues/#{issue_id_1}"
    last_response.should be_ok
    
    delete "/issues/#{issue_id_1}"
    last_response.should be_ok
    
    get "/issues/#{issue_id_1}"
    last_response.should be_not_found
  end
  
  it 'should not be able to remove a inexistent issue' do
    delete "/issues/00"
    last_response.should be_not_found
  end
  
  it 'should be able to add an issue' do
    post "/issues", ISSUE_CONTENT_1
    last_response.should be_redirect
    
    follow_redirect!
    (last_request.path =~ /\/issues\/[\w\d]{40}/).should == 0
    last_response.should be_ok
    last_response.body.should == ISSUE_CONTENT_1
  end
  
  after(:all) do
    teardown_environment
  end
  
end