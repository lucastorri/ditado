require File.expand_path(File.dirname(__FILE__) + '/ditado_test_helper')

describe Ditado::Core, 'when ditado is instaciated' do
  
  before(:each) do
    setup_environment
  end

  it 'should set a global flag with the ditado folder' do
    (defined? $DITADO_REPO).should be_false
    begin 
      FileUtils.mkdir DITADO_FILES_FOLDER
    rescue Exception
    end
    @ditado = Ditado::Core.new DITADO_TEST_ENVIRONMENT
    $DITADO_REPO.should == DITADO_TEST_ENVIRONMENT
  end

  it 'should check if ditado was not previously initialized on the given path' do
    begin
      @ditado = Ditado::Core.new DITADO_TEST_ENVIRONMENT
      fail
    rescue Ditado::DitadoNotInitializedException => e
    end
  end

end

describe Ditado::Core, 'when ditado is initialized on a given folder where' do
  
  before(:each) do
    setup_environment
  end
  
  context 'ditado was not initialized before' do
  
    it 'should create a .ditado folder' do
      (File.exists? DITADO_FILES_FOLDER).should be_false
      Ditado::Core.init(DITADO_TEST_ENVIRONMENT).should_not be_nil
      (File.directory?DITADO_FILES_FOLDER).should be_true
    end
  
    it 'should create a project details file' do
      (File.exists? DITADO_PROJECT_DESCRIPTION_FILE).should be_false
      Ditado::Core.init(DITADO_TEST_ENVIRONMENT).should_not be_nil
      (File.file? DITADO_PROJECT_DESCRIPTION_FILE).should be_true
      
      open(DITADO_PROJECT_DESCRIPTION_FILE) do |f|
        f.read.should == "Name: \nDescription: "
      end
    end
    
    it 'should create a wiki folder' do
      (File.exists? DITADO_WIKI_FOLDER).should be_false
      (File.exists? DITADO_WIKI_HOME_FILE).should be_false
      Ditado::Core.init(DITADO_TEST_ENVIRONMENT).should_not be_nil
      (File.directory?DITADO_WIKI_FOLDER).should be_true
      (File.file? DITADO_WIKI_HOME_FILE).should be_true
      open(DITADO_WIKI_HOME_FILE) do |f|
        f.read.should == 'h1. Welcome!'
      end
    end
    
    it 'should create a issues folder' do
      (File.exists? DITADO_ISSUES_FOLDER).should be_false
      Ditado::Core.init(DITADO_TEST_ENVIRONMENT).should_not be_nil
      (File.directory?DITADO_ISSUES_FOLDER).should be_true
    end
  
  end
  
  context 'ditado was already initialized' do
  
    before(:each) do
      begin 
        FileUtils.mkdir DITADO_FILES_FOLDER
      rescue Exception
      end
    end
  
    it 'should not modify anything' do
      (File.exists? DITADO_FILES_FOLDER).should be_true
      files_before = Dir.new(DITADO_FILES_FOLDER).entries
      must_throw_a Ditado::DitadoAlreadyInittedException do
        Ditado::Core.init DITADO_TEST_ENVIRONMENT
      end
      files_before.should == Dir.new(DITADO_FILES_FOLDER).entries
    end
    
  end
  
  after(:all) do
    teardown_environment
  end
  
end

describe Ditado, 'when working with issues' do
  
  before(:each) do
    setup_environment
    @ditado = Ditado::Core.init DITADO_TEST_ENVIRONMENT
  end
  
  context 'and creating issues' do
    
    before(:each) do
      @ditado.stub!(:diffstamp).and_return(TIME_NOW)
    end
    
    it 'should set the issue id as the SHA1 hash from the issue content plus the current time' do
      @ditado.issue_add(ISSUE_CONTENT_1).should == ISSUE_CONTENT_1_SHA1
      @ditado.issue_add(ISSUE_CONTENT_2).should == ISSUE_CONTENT_2_SHA1
    end
    
    it 'should be able to add and persist new issues' do
      issue_id_1 = @ditado.issue_add ISSUE_CONTENT_1
      issue_id_2 = @ditado.issue_add ISSUE_CONTENT_2

      open(ISSUE_CONTENT_1_FILE) do |f|
        f.read.should == ISSUE_CONTENT_1
      end

      open(ISSUE_CONTENT_2_FILE) do |f|
        f.read.should == ISSUE_CONTENT_2
      end    
    end
    
    it 'should not be able to create issues with same key' do
      @ditado.issue_add(ISSUE_CONTENT_1).should == ISSUE_CONTENT_1_SHA1
      content_before = ''
      open(ISSUE_CONTENT_1_FILE) do |f|
        content_before = f.read
      end
      
      must_throw_a  Ditado::IssueIDAlreadyExistentException do
        @ditado.issue_add(ISSUE_CONTENT_1)
      end
      open(ISSUE_CONTENT_1_FILE) do |f|
        f.read.should == content_before
      end
    end
    
    it 'should be able to identify if a issue exists' do
      issue_id_1 = @ditado.issue_add(ISSUE_CONTENT_1)
      @ditado.issue_exists?(issue_id_1).should be_true
      
      @ditado.issue_exists?('00').should be_false
    end
    
  end
  
  context 'and retrieving issues' do
  
    it 'should be able to retrieve existent issues' do
      issue_id_1 = @ditado.issue_add ISSUE_CONTENT_1
      issue_id_2 = @ditado.issue_add ISSUE_CONTENT_2
    
      @ditado.issue_get(issue_id_1).should == ISSUE_CONTENT_1
      @ditado.issue_get(issue_id_2).should == ISSUE_CONTENT_2
    end
    
    it 'should not retrieve anything when the issue does not exist' do
      must_throw_a Ditado::IssueIdNotExistentException do
        @ditado.issue_get('00')
      end
    end
    
    it 'should be able to list all existent issues' do
      @ditado.issue_list.empty?.should be_true
       
      issue_id_1 = @ditado.issue_add ISSUE_CONTENT_1
      @ditado.issue_list.should == [issue_id_1]
       
      issue_id_2 = @ditado.issue_add ISSUE_CONTENT_2
      (@ditado.issue_list - [issue_id_1, issue_id_2]).any?.should be_false
    end
  
  end
  
  context 'and removing issues' do
  
    it 'should return exception when the issue does not exist' do
      must_throw_a Ditado::IssueIdNotExistentException do
        @ditado.issue_del('00')
      end
    end
  
    it 'should be able to remove an existent issue' do
      issue_id_1 = @ditado.issue_add ISSUE_CONTENT_1
      @ditado.issue_del(issue_id_1)
      File.exists?(ISSUE_CONTENT_1_FILE).should be_false
    end
  
  end
  
  context 'and editing issues' do
    
    NEW_ISSUE_CONTENT_1 = 'When are you going to fix this?'
    
    before(:each) do
      @ditado.stub!(:diffstamp).and_return('2010-11-10 21:44:44 -0200')
      @ditado.issue_add(ISSUE_CONTENT_1)
    end
    
    it 'should be able to change the content of a issue' do
      content_before = ''
      open(ISSUE_CONTENT_1_FILE) do |f|
        content_before = f.read
      end
      
      @ditado.issue_edit(ISSUE_CONTENT_1_SHA1, NEW_ISSUE_CONTENT_1)
      open(ISSUE_CONTENT_1_FILE) do |f|
        f.read.should == NEW_ISSUE_CONTENT_1
      end
    end
    
    it 'should not be able to edit an inexistent issue' do
      must_throw_a Ditado::IssueIdNotExistentException do
        @ditado.issue_edit('00', NEW_ISSUE_CONTENT_1)
      end
    end
    
  end
  
  after(:each) do
    teardown_environment
  end
  
end

describe Ditado, 'when working with wiki pages' do
  
  before(:each) do
    setup_environment
    @ditado = Ditado::Core.init DITADO_TEST_ENVIRONMENT
  end
  
  context 'and creating pages' do

    it 'should use the slug title of the page as id' do
      @ditado.wiki_add(WIKI_PAGE_CONTENT_1).should == WIKI_PAGE_CONTENT_1_ID
      @ditado.wiki_add(WIKI_PAGE_CONTENT_2).should == WIKI_PAGE_CONTENT_2_ID
    end
    
    it 'should use the first line of the new page contents as its title' do
      must_throw_a Ditado::InvalidDitadoWikiPageNameException do
        @ditado.wiki_add(" ")
      end
      
      must_throw_a Ditado::InvalidDitadoWikiPageNameException do
        @ditado.wiki_add('*-*')
      end
      
      must_throw_a Ditado::InvalidDitadoWikiPageNameException do
        @ditado.wiki_add(" \n")
      end
      
      must_throw_a Ditado::InvalidDitadoWikiPageNameException do
        @ditado.wiki_add(":)")
      end
      
      @ditado.wiki_add('a').should == 'a'
    end
    
    it 'should be able do add a new page' do
      File.exists?(WIKI_PAGE_CONTENT_1_FILE).should be_false
      @ditado.wiki_add WIKI_PAGE_CONTENT_1
      File.file?(WIKI_PAGE_CONTENT_1_FILE).should be_true
      open(WIKI_PAGE_CONTENT_1_FILE) do |f|
        f.read.should == WIKI_PAGE_CONTENT_1
      end
    end
    
    it 'should not be able to override an existent page' do
      FileUtils.touch WIKI_PAGE_CONTENT_1_FILE
      must_throw_a Ditado::DitadoWikiPageAlreadyExistsException do
        @ditado.wiki_add WIKI_PAGE_CONTENT_1
      end
    end
    
  end
  
  after(:each) do
    teardown_environment
  end
  
end