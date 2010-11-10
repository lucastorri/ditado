require 'rspec'
require 'FileUtils'
require File.expand_path(File.dirname(__FILE__) + "/../src/ditado.rb")

describe Ditado, 'when ditado is initted' do

  DITADO_TEST_ENVIRONMENT = File.dirname(__FILE__) + "/run"
  DITADO_FILES_FOLDER = DITADO_TEST_ENVIRONMENT + '/.ditado'
  
  before(:all) do
    begin 
      FileUtils.mkdir DITADO_TEST_ENVIRONMENT
    rescue Exception
    end
  end
  
  it 'should create a .ditado folder on the given repo' do
    (File.exists? DITADO_FILES_FOLDER).should be_false
    ditado = Ditado.new DITADO_TEST_ENVIRONMENT
    ditado.init
    (File.exists? DITADO_FILES_FOLDER).should be_true
  end
  
  after(:all) do
    begin
      FileUtils.rm_rf DITADO_TEST_ENVIRONMENT
    rescue Exception
    end
  end
  
end
