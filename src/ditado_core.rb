require 'rubygems'
require 'FileUtils'

module Ditado
  
  RESOURCES_FOLDER = File.expand_path(File.dirname(__FILE__) + '/../res')
  SKELETON_FOLDER = RESOURCES_FOLDER + '/skeleton'

  REPO_FOLDER_NAME = '.ditado'
  PROJECT_DESC_FILE = 'project'

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
      raise DitadoAlreadyInitializedException.new if File.exists?(ditado_folder)
      FileUtils.cp_r(SKELETON_FOLDER, ditado_folder)
      Core.new(repo_path)
    end
    
    def self.register_module(prefix, module_class)
      raise InvalidModulePrefixException.new if not (prefix =~ /^[a-zA-Z][\da-zA-Z]*$/)
      @@modules[prefix] = module_class
    end
    
    def self.modules
      @@modules.dup
    end
    
    private
    def method_missing(symbol, *args)
      if symbol =~ /(^[a-zA-Z][a-zA-Z\d]*)_(.*)/ and @@modules[$1] then
        @@modules[$1].new(self).send($2, *args)
      else
        super.method_missing(symbol, *args)
      end
    end
  
  end
  
  class DitadoException < Exception
  end
  
  class DitadoAlreadyInitializedException < DitadoException
  end
  
  class DitadoNotInitializedException < DitadoException
  end
  
  class InvalidModulePrefixException < DitadoException
  end

end