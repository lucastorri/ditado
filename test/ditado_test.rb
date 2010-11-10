require 'rspec'
require 'FileUtils'
require File.expand_path(File.dirname(__FILE__) + '/../src/ditado.rb')

describe Ditado, 'when ditado is initted on a given folder where' do

  DITADO_TEST_ENVIRONMENT = File.dirname(__FILE__) + '/run'
  DITADO_FILES_FOLDER = DITADO_TEST_ENVIRONMENT + '/.ditado'
  DITADO_PROJECT_DESCRIPTION_FILE = DITADO_FILES_FOLDER + '/project'
  DITADO_WIKI_FOLDER = DITADO_FILES_FOLDER + '/wiki'
  DITADO_WIKI_HOME_FILE = DITADO_WIKI_FOLDER + '/index'
  DITADO_ISSUES_FOLDER = DITADO_FILES_FOLDER + '/issues'
  
  before(:each) do
    @ditado = Ditado.new DITADO_TEST_ENVIRONMENT
    begin 
      FileUtils.mkdir DITADO_TEST_ENVIRONMENT
    rescue Exception
    end
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
      
      open(DITADO_PROJECT_DESCRIPTION_FILE).read.should == 
      "Name: \n" +
      'Description: '
    end
    
    it 'should create a wiki folder' do
      (File.exists? DITADO_WIKI_FOLDER).should be_false
      (File.exists? DITADO_WIKI_HOME_FILE).should be_false
      @ditado.init.should be_true
      (File.directory?DITADO_WIKI_FOLDER).should be_true
      (File.file? DITADO_WIKI_HOME_FILE).should be_true
      open(DITADO_WIKI_HOME_FILE).read.should == 'Welcome!'
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
    begin
      FileUtils.rm_rf DITADO_TEST_ENVIRONMENT
    rescue Exception
    end
  end
  
end
