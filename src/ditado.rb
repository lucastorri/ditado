require 'FileUtils'

class Ditado
  
  REPO_FOLDER_NAME = '.ditado'
  
  def initialize(repo_path)
    @repo_path = repo_path
  end
  
  def init
    FileUtils.mkdir @repo_path + '/' + REPO_FOLDER_NAME
  end
  
end