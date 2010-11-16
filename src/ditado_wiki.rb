require File.expand_path(File.dirname(__FILE__) + '/../src/ditado_util')

module Ditado
  
  WIKI_FOLDER_NAME = 'wiki'
  WIKI_HOME_FILE = 'index'
  
  class WikiWiki
    
    def initialize(ditado)
      @ditado = ditado
      @wiki_folder = "#{@ditado.folder}/#{WIKI_FOLDER_NAME}"
    end
    
    def add(content)
      new_page_id = wiki_page_id(content)
      raise InvalidDitadoWikiPageNameException.new if new_page_id.strip == ''
      raise DitadoWikiPageAlreadyExistsException.new if exists?(new_page_id)
      Ditado::Util.write wiki_page_file(new_page_id), content
      new_page_id
    end
    
    def get(id)
      raise DitadoWikiPageDoesNotExistException.new if not exists? id
      Ditado::Util.read(wiki_page_file(id))
    end
    
    def textile(id)
      RedCloth.new('h1. ' + get(id)).to_html
    end
    
    def exists?(id)
      File.exists?(wiki_page_file(id))
    end
    
    def del(id)
      raise DitadoWikiPageDoesNotExistException.new if not exists? id
      FileUtils.rm wiki_page_file(id)
    end
    
    def edit(id, new_content)
      if wiki_page_id(new_content) != id then
        del(id)
        add(new_content)
      else
        raise DitadoWikiPageDoesNotExistException.new if not exists? id
        Ditado::Util.write wiki_page_file(id), new_content
        id
      end
    end
    
    private
    def wiki_page_file(id)
      "#{@wiki_folder}/#{id}"
    end
    
    def wiki_page_id(content)
      content.split("\n")[0].to_slug.normalize.to_s
    end
    
  end
  
end

Ditado::Core.register_module('wiki', Ditado::WikiWiki)