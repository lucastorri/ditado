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

  class Core
    
    @@modules = {}
    attr_accessor :repo_path, :folder
  
    def initialize(repo_path)
      @repo_path = $DITADO_REPO = repo_path
      @folder = "#{repo_path}/#{REPO_FOLDER_NAME}"
      raise DitadoNotInitializedException.new if !File.exists?(@folder)
      @wiki_folder = "#{@folder}/#{WIKI_FOLDER_NAME}"
    end
  
    def self.init(repo_path)
      ditado_folder = "#{repo_path}/#{REPO_FOLDER_NAME}"
      raise DitadoAlreadyInittedException.new if File.exists?(ditado_folder)
      FileUtils.cp_r(SKELETON_FOLDER, ditado_folder)
      Core.new(repo_path)
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
    
    def self.register_module(prefix, module_class)
      @@modules[prefix] = module_class
    end
    
    def self.modules
      @@modules.dup
    end
    
    private
    def wiki_page_file(id)
      "#{@wiki_folder}/#{id}"
    end
    
    def wiki_page_id(content)
      content.split("\n")[0].to_slug.normalize.to_s
    end
    
    def method_missing(symbol, *args)
      if symbol =~ /(\w[\w\d]*)_(\w.*)/ and @@modules[$1] then
        @@modules[$1].new(self).send($2, *args)
      else
        super.method_missing(symbol, *args)
      end
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
  
  end

end