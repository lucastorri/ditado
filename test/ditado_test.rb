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
  ISSUE_MESSAGE_1_SHA1 = '53863f107a09de9df9d6a947d710631cc2b7dadf'
  ISSUE_MESSAGE_1_FILE = "#{DITADO_ISSUES_FOLDER}/#{ISSUE_MESSAGE_1_SHA1}"
  ISSUE_MESSAGE_2 = 'It is still not working, dam you!'
  ISSUE_MESSAGE_2_SHA1 = 'd8285e8384b6a4dac9f9da79fdd85f3bbf214dec'
  ISSUE_MESSAGE_2_FILE = "#{DITADO_ISSUES_FOLDER}/#{ISSUE_MESSAGE_2_SHA1}"
  
  before(:each) do
    setup_environment
    @ditado = Ditado::Ditado.new DITADO_TEST_ENVIRONMENT
    @ditado.init
  end
  
  # ID must the hash of the file, otherwise will conflict in a distribute environment
  
  context 'and creating issues' do
    
    it 'should set the issue ids as SHA1 hash keys from the issue message' do
      @ditado.issue_add(ISSUE_MESSAGE_1).should == ISSUE_MESSAGE_1_SHA1
      @ditado.issue_add(ISSUE_MESSAGE_2).should == ISSUE_MESSAGE_2_SHA1
    end
    
    it 'should be able to add and persist new issues' do
      issue_id_1 = @ditado.issue_add ISSUE_MESSAGE_1
      issue_id_2 = @ditado.issue_add ISSUE_MESSAGE_2

      open(ISSUE_MESSAGE_1_FILE) do |f|
        f.read.should == ISSUE_MESSAGE_1
      end

      open(ISSUE_MESSAGE_2_FILE) do |f|
        f.read.should == ISSUE_MESSAGE_2
      end    
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
      @ditado.issue_get('00').should be_nil
    end
  
  end
  
  context 'and removing issues' do
  
    it 'should return false when the issue does not exist' do
      @ditado.issue_del('00').should be_false
    end
  
    it 'should be able to remove an existent issue' do
      issue_id_1 = @ditado.issue_add ISSUE_MESSAGE_1
      @ditado.issue_del(issue_id_1).should be_true
      File.exists?(ISSUE_MESSAGE_1_FILE).should be_false
    end
  
  end
  
  after(:each) do
    teardown_environment
  end
  
end