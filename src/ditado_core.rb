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
    
    def self.register_module(prefix, module_class)
      @@modules[prefix] = module_class
    end
    
    def self.modules
      @@modules.dup
    end
    
    private
    def method_missing(symbol, *args)
      if symbol =~ /(\w[\w\d]*)_(\w.*)/ and @@modules[$1] then
        @@modules[$1].new(self).send($2, *args)
      else
        super.method_missing(symbol, *args)
      end
    end
  
  end

end