require 'rubygems'
require 'FileUtils'
require 'digest/sha1'
require 'sinatra/base'

module Ditado
  
  RESOURCES_FOLDER = File.expand_path(File.dirname(__FILE__) + '/../res')
  SKELETON_FOLDER = RESOURCES_FOLDER + '/skeleton'
  SERVER_SCOPE = 'localhost'
  SERVER_PORT = 9317

  REPO_FOLDER_NAME = '.ditado'
  PROJECT_DESC_FILE = 'project'
  WIKI_FOLDER_NAME = 'wiki'
  WIKI_HOME_FILE = 'index'
  ISSUES_FOLDER_NAME = 'issues'

  class Core
  
    def initialize(repo_path)
      @repo_path = $DITADO_REPO = repo_path
      @ditado_folder = "#{repo_path}/#{REPO_FOLDER_NAME}"
      raise DitadoNotInitializedException.new if !File.exists?(@ditado_folder)
      @issues_folder = "#{@ditado_folder}/#{ISSUES_FOLDER_NAME}"
    end
  
    def self.init(repo_path)
      ditado_folder = "#{repo_path}/#{REPO_FOLDER_NAME}"
      raise DitadoAlreadyInittedException.new if File.exists?(ditado_folder)
      FileUtils.cp_r(SKELETON_FOLDER, ditado_folder)
      Core.new(repo_path)
    end
    
    def issue_add(content)
      new_issue_id = Digest::SHA1.hexdigest(content + diffstamp)
      raise IssueIDAlreadyExistentException.new if issue_exists?(new_issue_id)
      open(issue_file(new_issue_id), 'w') do |f|
        f.write content
      end
      new_issue_id
    end
    
    def issue_get(id)
      raise IssueIdNotExistentException.new if !issue_exists?(id)
      open(issue_file(id)) do |f|
        return f.read
      end
    end
    
    def issue_edit(id, new_content)
      raise IssueIdNotExistentException.new if !issue_exists?(id)
      open(issue_file(id), 'w') do |f|
        return f.write new_content
      end
    end
    
    def issue_del(id)
      raise IssueIdNotExistentException.new if !issue_exists?(id)
      FileUtils.rm issue_file(id)
    end
    
    def issue_exists?(id)
      File.exists?(issue_file(id))
    end
    
    def ui_start
      DitadoWebClient.run! :host => SERVER_SCOPE, :port => SERVER_PORT
    end
    
    private
    def issue_file(id)
      issue_file = "#{@issues_folder}/#{id}"
    end
    
    def diffstamp
       Time.now.to_s
    end
  
  end

end