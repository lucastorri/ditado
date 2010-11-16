require 'rubygems'
require 'FileUtils'
require 'digest/sha1'
require 'sinatra/base'
require 'babosa'
require 'RedCloth'

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
    
    @@modules = {}
  
    def initialize(repo_path)
      @repo_path = $DITADO_REPO = repo_path
      @ditado_folder = "#{repo_path}/#{REPO_FOLDER_NAME}"
      raise DitadoNotInitializedException.new if !File.exists?(@ditado_folder)
      @issues_folder = "#{@ditado_folder}/#{ISSUES_FOLDER_NAME}"
      @wiki_folder = "#{@ditado_folder}/#{WIKI_FOLDER_NAME}"
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
      write issue_file(new_issue_id), content
      new_issue_id
    end
    
    def issue_get(id)
      raise IssueIdNotExistentException.new if !issue_exists?(id)
      read issue_file(id)
    end
    
    def issue_edit(id, new_content)
      raise IssueIdNotExistentException.new if !issue_exists?(id)
      write issue_file(id), new_content
    end
    
    def issue_del(id)
      raise IssueIdNotExistentException.new if !issue_exists?(id)
      FileUtils.rm issue_file(id)
    end
    
    def issue_list
      Dir.new(@issues_folder).entries - ['.', '..']
    end
    
    def issue_exists?(id)
      File.exists?(issue_file(id))
    end
    
    def ui_start
      Ditado::WebClient.run! :host => SERVER_SCOPE, :port => SERVER_PORT
    end
    
    def wiki_add(content)
      new_page_id = wiki_page_id(content)
      raise InvalidDitadoWikiPageNameException.new if new_page_id.strip == ''
      raise DitadoWikiPageAlreadyExistsException.new if wiki_exists?(new_page_id)
      write wiki_page_file(new_page_id), content
      new_page_id
    end
    
    def wiki_get(id)
      raise DitadoWikiPageDoesNotExistException.new if not wiki_exists? id
      read(wiki_page_file(id))
    end
    
    def wiki_textile(id)
      RedCloth.new('h1. ' + wiki_get(id)).to_html
    end
    
    def wiki_exists?(id)
      File.exists?(wiki_page_file(id))
    end
    
    def wiki_del(id)
      raise DitadoWikiPageDoesNotExistException.new if not wiki_exists? id
      FileUtils.rm wiki_page_file(id)
    end
    
    def wiki_edit(id, new_content)
      if wiki_page_id(new_content) != id then
        wiki_del(id)
        wiki_add(new_content)
      else
        raise DitadoWikiPageDoesNotExistException.new if not wiki_exists? id
        write wiki_page_file(id), new_content
        id
      end
    end
    
    def self.register_module(mod)
      @@modules[mod.prefix] = mod
    end
    
    private
    def issue_file(id)
      issue_file = "#{@issues_folder}/#{id}"
    end
    
    def wiki_page_file(id)
      "#{@wiki_folder}/#{id}"
    end
    
    def wiki_page_id(content)
      content.split("\n")[0].to_slug.normalize.to_s
    end
    
    def diffstamp
       Time.now.to_s
    end
    
    def read(file)
      open(file) do |f|
        return f.read
      end
    end
    
    def write(file, content)
      open(file, 'w') do |f|
        f.write content
      end
    end
    
    def method_missing(symbol, *args)
      if symbol =~ /(\w[\w\d]*)_(\w.*)/ and @@modules[$1] then
        @@modules[$1].module_class.new(self).send($2, *args)
      else
        super.method_missing(symbol, *args)
      end
    end
  
  end

end