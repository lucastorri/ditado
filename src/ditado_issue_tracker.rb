require File.expand_path(File.dirname(__FILE__) + '/../src/ditado_util')
require 'FileUtils'

module Ditado

  ISSUES_FOLDER_NAME = 'issues'

  class IssueTracker
    
    def initialize(ditado)
      @ditado = ditado
      @issues_folder = "#{@ditado.folder}/#{ISSUES_FOLDER_NAME}"
    end
    
    def add(content)
      new_issue_id = Digest::SHA1.hexdigest(content + diffstamp)
      raise IssueIDAlreadyExistentException.new if exists?(new_issue_id)
      Ditado::Util.write(issue_file(new_issue_id), content)
      new_issue_id
    end
    
    def get(id)
      raise IssueIdNotExistentException.new if !exists?(id)
      Ditado::Util.read(issue_file(id))
    end
    
    def edit(id, new_content)
      raise IssueIdNotExistentException.new if !exists?(id)
      Ditado::Util.write(issue_file(id), new_content)
    end
    
    def del(id)
      raise IssueIdNotExistentException.new if !exists?(id)
      FileUtils.rm issue_file(id)
    end
    
    def list
      Dir.new(@issues_folder).entries - ['.', '..']
    end
    
    def exists?(id)
      File.exists?(issue_file(id))
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

Ditado::Core.register_module('issue', Ditado::IssueTracker)