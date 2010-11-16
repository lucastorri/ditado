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
  
  it 'should know where is the repo and ditado folders' do
    begin 
      FileUtils.mkdir DITADO_FILES_FOLDER
    rescue Exception
    end
    @ditado = Ditado::Core.new DITADO_TEST_ENVIRONMENT
    @ditado.repo_path.should == DITADO_TEST_ENVIRONMENT
    @ditado.folder.should == DITADO_FILES_FOLDER
  end

  it 'should check if ditado was not previously initialized on the given path' do
    should_raise_a Ditado::DitadoNotInitializedException do
      @ditado = Ditado::Core.new DITADO_TEST_ENVIRONMENT
    end
  end
  
  it 'should be able to register modules' do
    Ditado::Core.respond_to?(:register_module).should be_true
    @ditado = Ditado::Core.init(DITADO_TEST_ENVIRONMENT)
    
    class TestModule
      
      def self.ditado=(ditado)
        @@ditado = ditado
      end
      
      def initialize(ditado)
        @@ditado.should == ditado
      end
      
      def call1
        true
      end
      
      def call2
        true
      end

    end
    TestModule.ditado = @ditado
    
    should_raise_a NoMethodError do
      @ditado.test_call1
    end
    should_raise_a NoMethodError do
      @ditado.test_call2
    end
    Ditado::Core.register_module('test', TestModule)
    @ditado.test_call1.should be_true
    @ditado.test_call2.should be_true
  end
  
  it 'should only allow modules with valid prefix' do
    [' ', '/asd', '**', '_a', 'invalid_prefix', '31asd'].each do |invalid_prefix|
      should_raise_a Ditado::InvalidModulePrefixException do
        Ditado::Core.register_module(invalid_prefix, nil)
      end
    end
    
    ["prefix", 'anotherOne', 'THISTOO'].each do |valid_prefix|
      Ditado::Core.register_module(valid_prefix, nil)
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
        f.read.should == "Index"
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
      should_raise_a Ditado::DitadoAlreadyInitializedException do
        Ditado::Core.init DITADO_TEST_ENVIRONMENT
      end
      files_before.should == Dir.new(DITADO_FILES_FOLDER).entries
    end
    
  end
  
  after(:all) do
    teardown_environment
  end
  
end
