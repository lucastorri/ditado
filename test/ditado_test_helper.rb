require 'rubygems'
require 'rspec'
require 'FileUtils'
require 'date'
require 'digest/sha1'
require 'rack/test'
require File.expand_path(File.dirname(__FILE__) + '/../src/ditado_core')
require File.expand_path(File.dirname(__FILE__) + '/../src/ditado_web_client')
require File.expand_path(File.dirname(__FILE__) + '/../src/ditado_exceptions')

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