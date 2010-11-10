require 'rspec'
require 'FileUtils'
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
  
  context 'ditado not initted' do
  
    it 'should create a .ditado folder' do
      (File.exists? DITADO_FILES_FOLDER).should be_false
      @ditado.init.should be_true
      (File.directory?DITADO_FILES_FOLDER).should be_true
    end
  
    it 'should create a project details file' do
      (File.exists? DITADO_PROJECT_DESCRIPTION_FILE).should be_false
      @ditado.init.should be_true
      (File.file? DITADO_PROJECT_DESCRIPTION_FILE).should be_true
      
      open(DITADO_PROJECT_DESCRIPTION_FILE) do |f|
        f.read.should == "Name: \nDescription: "
      end
    end
    
    it 'should create a wiki folder' do
      (File.exists? DITADO_WIKI_FOLDER).should be_false
      (File.exists? DITADO_WIKI_HOME_FILE).should be_false
      @ditado.init.should be_true
      (File.directory?DITADO_WIKI_FOLDER).should be_true
      (File.file? DITADO_WIKI_HOME_FILE).should be_true
      open(DITADO_WIKI_HOME_FILE) do |f|
        f.read.should == 'Welcome!'
      end
    end
    
    it 'should create a issues folder' do
      (File.exists? DITADO_ISSUES_FOLDER).should be_false
      @ditado.init.should be_true
      (File.directory?DITADO_ISSUES_FOLDER).should be_true
    end
  
  end
  
  context 'ditado already innited' do
  
    before(:each) do
      begin 
        FileUtils.mkdir DITADO_FILES_FOLDER
      rescue Exception
      end
    end
  
    it 'should not modify anything' do
      (File.exists? DITADO_FILES_FOLDER).should be_true
      files_before = Dir.new(DITADO_FILES_FOLDER).entries
      @ditado.init.should be_false
      files_before.should == Dir.new(DITADO_FILES_FOLDER).entries
    end
    
  end
  
  after(:each) do
    teardown_environment
  end
  
end

describe Ditado, 'when working with issues' do
  
  ISSUE_MESSAGE_1 = 'This software does not work.'
  ISSUE_MESSAGE_2 = 'It is still not working, dam you!'
  
  before(:each) do
    setup_environment
    @ditado = Ditado::Ditado.new DITADO_TEST_ENVIRONMENT
    @ditado.init
  end
  
  it 'should be able to add and persist new issues' do
    issue_id_1 = @ditado.issue_add ISSUE_MESSAGE_1
    issue_id_2 = @ditado.issue_add ISSUE_MESSAGE_2
    
    open("#{DITADO_ISSUES_FOLDER}/0") do |f|
      f.read.should == ISSUE_MESSAGE_1
    end
    
    open("#{DITADO_ISSUES_FOLDER}/1") do |f|
      f.read.should == ISSUE_MESSAGE_2
    end    
  end
  
  context 'and retrieving issues' do
  
    it 'should be able to retrieve existent issues' do
      issue_id_1 = @ditado.issue_add ISSUE_MESSAGE_1
      issue_id_2 = @ditado.issue_add ISSUE_MESSAGE_2
    
      @ditado.issue_get(issue_id_1).should == ISSUE_MESSAGE_1
      @ditado.issue_get(issue_id_2).should == ISSUE_MESSAGE_2
    end
    
    it 'should return nil when the issue does not exist' do
      @ditado.issue_get(51).should be_nil
    end
  
  end
  
  after(:each) do
    teardown_environment
  end
  
end