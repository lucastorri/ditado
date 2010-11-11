require 'rspec'
require 'FileUtils'
require 'date'
require 'digest/sha1'
require File.expand_path(File.dirname(__FILE__) + '/../src/ditado.rb')

DITADO_TEST_ENVIRONMENT = File.dirname(__FILE__) + '/run'
DITADO_FILES_FOLDER = DITADO_TEST_ENVIRONMENT + '/.ditado'
DITADO_PROJECT_DESCRIPTION_FILE = DITADO_FILES_FOLDER + '/project'
DITADO_WIKI_FOLDER = DITADO_FILES_FOLDER + '/wiki'
DITADO_WIKI_HOME_FILE = DITADO_WIKI_FOLDER + '/index'
DITADO_ISSUES_FOLDER = DITADO_FILES_FOLDER + '/issues'

def setup_environment
  begin 
    FileUtils.mkdir DITADO_TEST_ENVIRONMENT
  rescue Exception
  end
end

def teardown_environment
  begin
    FileUtils.rm_rf DITADO_TEST_ENVIRONMENT
  rescue Exception
  end
end

describe Ditado, 'when ditado is initted on a given folder where' do
  
  before(:each) do
    @ditado = Ditado::Ditado.new DITADO_TEST_ENVIRONMENT
    setup_environment
  end
  
  context 'ditado was not initted' do
  
    it 'should create a .ditado folder' do
      (File.exists? DITADO_FILES_FOLDER).should be_false
      @ditado.init
      (File.directory?DITADO_FILES_FOLDER).should be_true
    end
  
    it 'should create a project details file' do
      (File.exists? DITADO_PROJECT_DESCRIPTION_FILE).should be_false
      @ditado.init
      (File.file? DITADO_PROJECT_DESCRIPTION_FILE).should be_true
      
      open(DITADO_PROJECT_DESCRIPTION_FILE) do |f|
        f.read.should == "Name: \nDescription: "
      end
    end
    
    it 'should create a wiki folder' do
      (File.exists? DITADO_WIKI_FOLDER).should be_false
      (File.exists? DITADO_WIKI_HOME_FILE).should be_false
      @ditado.init
      (File.directory?DITADO_WIKI_FOLDER).should be_true
      (File.file? DITADO_WIKI_HOME_FILE).should be_true
      open(DITADO_WIKI_HOME_FILE) do |f|
        f.read.should == 'Welcome!'
      end
    end
    
    it 'should create a issues folder' do
      (File.exists? DITADO_ISSUES_FOLDER).should be_false
      @ditado.init
      (File.directory?DITADO_ISSUES_FOLDER).should be_true
    end
  
  end
  
  context 'ditado was already innited' do
  
    before(:each) do
      begin 
        FileUtils.mkdir DITADO_FILES_FOLDER
      rescue Exception
      end
    end
  
    it 'should not modify anything' do
      (File.exists? DITADO_FILES_FOLDER).should be_true
      files_before = Dir.new(DITADO_FILES_FOLDER).entries
      begin
        @ditado.init
        fail
      rescue Ditado::DitadoAlreadyInittedException => e
      end
      files_before.should == Dir.new(DITADO_FILES_FOLDER).entries
    end
    
  end
  
  after(:each) do
    teardown_environment
  end
  
end

describe Ditado, 'when working with issues' do
  
  TIME_NOW = '2010-11-10 21:44:44 -0200'
  ISSUE_CONTENT_1 = 'This software does not work.'
  ISSUE_CONTENT_1_SHA1 = '557697b22fadce5e580b85eec520d8d3e67d1da3'
  ISSUE_CONTENT_1_FILE = "#{DITADO_ISSUES_FOLDER}/#{ISSUE_CONTENT_1_SHA1}"
  ISSUE_CONTENT_2 = 'It is still not working, dam you!'
  ISSUE_CONTENT_2_SHA1 = '4a5f26421fcc2d1d92174b920ef4729a05858254'
  ISSUE_CONTENT_2_FILE = "#{DITADO_ISSUES_FOLDER}/#{ISSUE_CONTENT_2_SHA1}"
  
  before(:each) do
    setup_environment
    @ditado = Ditado::Ditado.new DITADO_TEST_ENVIRONMENT
    @ditado.init
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
      
      begin
        @ditado.issue_add(ISSUE_CONTENT_1)
        fail
      rescue Ditado::IssueIDAlreadyExistentException => e
      end
      open(ISSUE_CONTENT_1_FILE) do |f|
        f.read.should == content_before
      end
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
      begin
        @ditado.issue_get('00')
        fail
      rescue Ditado::IssueIdNotExistentException => e
      end
    end
  
  end
  
  context 'and removing issues' do
  
    it 'should return exception when the issue does not exist' do
      begin
        @ditado.issue_del('00')
        fail
      rescue Ditado::IssueIdNotExistentException => e
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
      begin
        @ditado.issue_edit('00', NEW_ISSUE_CONTENT_1)
        fail
      rescue Ditado::IssueIdNotExistentException => e
      end
    end
    
  end
  
  after(:each) do
    teardown_environment
  end
  
end

describe Ditado, 'when using UI' do
  
  it 'starts the web client when receive the ui start command' do
    
  end
  
end
