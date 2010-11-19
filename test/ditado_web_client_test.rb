require File.expand_path(File.dirname(__FILE__) + '/ditado_test_helper')

describe Ditado::WebClient, 'when using UI' do
  
  include Rack::Test::Methods

  def app
    Ditado::WebClient
  end
  
  it 'should be a module' do
    Ditado::Core.modules['ui'].should == Ditado::WebUI
  end
  
  before(:each) do
    setup_environment
    @ditado = Ditado::Core.init DITADO_TEST_ENVIRONMENT
  end
  
  it 'should provide a index page' do
    get '/'
    last_response.should be_ok
  end
  
  it 'should have a issues page' do
    get '/issues'
    last_response.should be_ok
  end

  it 'should be able to add an issue' do
    post "/issues", :content => ISSUE_CONTENT_1
    last_response.should be_redirect

    follow_redirect!
    (last_request.path =~ /\/issues\/[\w\d]{40}/).should == 0
    last_response.should be_ok
  end
  
  it 'should have a page for each issue' do
    issue_id_1 = @ditado.issue_add ISSUE_CONTENT_1
    issue_id_2 = @ditado.issue_add ISSUE_CONTENT_2
    
    get "/issues/#{issue_id_1}"
    last_response.should be_ok

    get "/issues/#{issue_id_2}"
    last_response.should be_ok
  end
  
  it 'should be able to remove a issue' do
    issue_id_1 = @ditado.issue_add ISSUE_CONTENT_1
    
    get "/issues/#{issue_id_1}"
    last_response.should be_ok
    
    delete "/issues/#{issue_id_1}"
    last_response.should be_redirect
    
    get "/issues/#{issue_id_1}"
    last_response.should be_not_found
  end
  
  it 'should have a page to add new issues' do
    get '/issues_new'
    last_response.should be_ok
  end
  
  it 'should not be able to remove a inexistent issue' do
    delete '/issues/00'
    last_response.should be_not_found
  end
  
  it 'should be able to edit a existent issue' do
    issue_id_1 = @ditado.issue_add ISSUE_CONTENT_1
    
    put "/issues/#{issue_id_1}", :content => ISSUE_CONTENT_2
    put_path = last_request.path
    last_response.should be_redirect
    
    follow_redirect!
    last_request.path.should == put_path
    last_response.should be_ok
  end
  
  it 'should not be able to edit a inexistent issue' do
    put '/issues/00', ISSUE_CONTENT_2
    last_response.should be_not_found
  end
  
  it 'should have a wiki page' do
    get '/wiki/index'
    last_response.should be_ok
  end
  
  it 'should parse textile files using the page parameter' do
    @ditado.wiki_add Ditado::WikiPage.new(WIKI_PAGE_CONTENT_1_TITLE, WIKI_PAGE_CONTENT_1)
    get '/wiki/welcome'
    last_response.should be_ok
  end
  
  after(:all) do
    teardown_environment
  end
  
end