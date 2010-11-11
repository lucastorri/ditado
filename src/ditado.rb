require 'FileUtils'
require 'digest/sha1'

module Ditado
  
  RESOURCES_FOLDER = File.expand_path(File.dirname(__FILE__) + '/../res')
  SKELETON_FOLDER = RESOURCES_FOLDER + '/skeleton'

  REPO_FOLDER_NAME = '.ditado'
  PROJECT_DESC_FILE = 'project'
  WIKI_FOLDER_NAME = 'wiki'
  WIKI_HOME_FILE = 'index'
  ISSUES_FOLDER_NAME = 'issues'

  class Ditado
  
    def initialize(repo_path)
      @repo_path = repo_path
      @ditado_folder = "#{@repo_path}/#{REPO_FOLDER_NAME}"
      @issues_folder = "#{@ditado_folder}/#{ISSUES_FOLDER_NAME}"
    end
  
    def init
      begin
        throw Exception.new('Folder already exists') if File.exists? @ditado_folder
        FileUtils.cp_r(SKELETON_FOLDER, @ditado_folder)
        return true
      rescue
        return false
      end
    end
    
    def issue_add(content)
      new_issue_id = Digest::SHA1.hexdigest(content + diffstamp)
      issue_file = "#{@issues_folder}/#{new_issue_id}"
      if File.exists? issue_file then
        new_issue_id = ''
      else
        open(issue_file, 'w') do |f|
          f.write content
        end
      end
      new_issue_id
    end
    
    def issue_get(id)
      issue_file = "#{@issues_folder}/#{id}"
      if File.exists? issue_file then
        open(issue_file) do |f|
          return f.read
        end
      end
    end
    
    def issue_edit(id, content)
      issue_file = "#{@issues_folder}/#{id}"
      if File.exists? issue_file then
        open(issue_file, 'w') do |f|
          return f.write content
        end
        true
      else
        false
      end
    end
    
    def issue_del(id)
      issue_file = "#{@issues_folder}/#{id}"
      if File.exists? issue_file then
        FileUtils.rm issue_file
        true
      else
        false
      end
    end
    
    def diffstamp
       Time.now.to_s
    end
  
  end

end