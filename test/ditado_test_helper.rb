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

TIME_NOW = '2010-11-10 21:44:44 -0200'
ISSUE_CONTENT_1 = 'This software does not work.'
ISSUE_CONTENT_1_SHA1 = '557697b22fadce5e580b85eec520d8d3e67d1da3'
ISSUE_CONTENT_1_FILE = "#{DITADO_ISSUES_FOLDER}/#{ISSUE_CONTENT_1_SHA1}"
ISSUE_CONTENT_2 = 'It is still not working, dam you!'
ISSUE_CONTENT_2_SHA1 = '4a5f26421fcc2d1d92174b920ef4729a05858254'
ISSUE_CONTENT_2_FILE = "#{DITADO_ISSUES_FOLDER}/#{ISSUE_CONTENT_2_SHA1}"

def setup_environment
  teardown_environment
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