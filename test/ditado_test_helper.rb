require 'rubygems'
require 'rspec'
require 'FileUtils'
require 'date'
require 'digest/sha1'
require 'rack/test'
require File.expand_path(File.dirname(__FILE__) + '/../src/ditado_core')
require File.expand_path(File.dirname(__FILE__) + '/../src/ditado_issue_tracker')
require File.expand_path(File.dirname(__FILE__) + '/../src/ditado_wiki')
require File.expand_path(File.dirname(__FILE__) + '/../src/ditado_web_client')
require File.expand_path(File.dirname(__FILE__) + '/../src/ditado_exceptions')
require File.expand_path(File.dirname(__FILE__) + '/../src/ditado_util')

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

WIKI_PAGE_CONTENT_1 = %q{Welcome...

**to DITado!**
}
WIKI_PAGE_CONTENT_1_ID = 'welcome'
WIKI_PAGE_CONTENT_1_FILE = "#{DITADO_WIKI_FOLDER}/#{WIKI_PAGE_CONTENT_1_ID}"
WIKI_PAGE_CONTENT_2 = %q{Welcome to this **new** page!

h2. and the text goes on... 
# 1
# 2
}
WIKI_PAGE_CONTENT_2_ID = 'welcome-to-this-new-page'
WIKI_PAGE_CONTENT_2_FILE = "#{DITADO_WIKI_FOLDER}/#{WIKI_PAGE_CONTENT_2_ID}"
WIKI_PAGE_CONTENT_2_AS_TEXTILE = %q{<h1>Welcome to this <b>new</b> page!</h1>
<h2>and the text goes on&#8230;</h2>
<ol>
	<li>1</li>
	<li>2</li>
</ol>}

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

def should_raise_a(exception_class, &code)
  begin
    code.call
    fail
  rescue exception_class => e
  end
end