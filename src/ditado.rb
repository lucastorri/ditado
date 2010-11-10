require 'FileUtils'

RESOURCES_FOLDER = File.expand_path(File.dirname(__FILE__) + '/../res')
SKELETON_FOLDER = RESOURCES_FOLDER + '/skeleton'

class Ditado
  
  REPO_FOLDER_NAME = '.ditado'
  PROJECT_DESC_FILE = 'project'
  WIKI_FOLDER_NAME = 'wiki'
  WIKI_HOME_FILE = 'index'
  ISSUES_FOLDER_NAME = 'issues'
  
  def initialize(repo_path)
    @repo_path = repo_path
    @ditado_folder = @repo_path + '/' + REPO_FOLDER_NAME
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
  
end