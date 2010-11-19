require 'rubygems'
require 'FileUtils'
require 'babosa'
require 'RedCloth'
require 'hpricot'
require File.expand_path(File.dirname(__FILE__) + '/../src/ditado_util')

module Ditado
  
  WIKI_FOLDER_NAME = 'wiki'
  WIKI_HOME_FILE = 'index'
  
  class WikiPage
    
    attr_accessor :title, :content, :original_id
    attr_writer :wikiwiki
    
    def initialize(title, content='', original_id=nil)
      @title = title
      @content = content
      @wikiwiki = nil
      @original_id = original_id
    end
    
    def id
      title.to_slug.normalize.to_s
    end
    
    def to_raw
      "<page><title>#{title}</title><content>#{content}</content></page>"
    end
    
    def to_html
      RedCloth.new(content).to_html
    end
    
    def save!
      @wikiwiki.edit(self)
    end
    
    def remove!
      @wikiwiki.del(self)
    end
    
    def self.load(id, raw, wikiwiki)
      raw_elements = Hpricot(raw).search('/page/*').to_a.inject({}) { |elements, elem| elements[elem.name.to_sym] = elem.to_plain_text; elements }
      page = new(raw_elements[:title], raw_elements[:content], id)
      page.wikiwiki = wikiwiki
      page
    end
    
  end
  
  class WikiWiki
    
    def initialize(ditado)
      @ditado = ditado
      @wiki_folder = "#{@ditado.folder}/#{WIKI_FOLDER_NAME}"
    end
    
    def add(new_page)
      raise InvalidDitadoWikiPageNameException.new if new_page.id == ''
      raise DitadoWikiPageAlreadyExistsException.new if exists?(new_page.id)
      Ditado::Util.write wiki_page_file(new_page.id), new_page.to_raw
      new_page.wikiwiki = self
      new_page.original_id = new_page.id
      new_page
    end
    
    def get(id)
      raise DitadoWikiPageDoesNotExistException.new if not exists? id
      WikiPage.load(id, Ditado::Util.read(wiki_page_file(id)), self)
    end
    
    def exists?(id)
      File.exists?(wiki_page_file(id))
    end
    
    def del(page)
      raise DitadoWikiPageDoesNotExistException.new if not exists? (page.original_id || page.id)
      FileUtils.rm wiki_page_file(page.original_id || page.id)
    end
    
    def edit(page)
      if page.original_id != page.id then
        del(page)
        add(page)
      else
        raise DitadoWikiPageDoesNotExistException.new if not exists? page.id
        Ditado::Util.write wiki_page_file(page.id), page.to_raw
        page
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
  
  class DitadoWikiPageAlreadyExistsException < DitadoException
  end
  
  class InvalidDitadoWikiPageNameException < DitadoException
  end
  
  class DitadoWikiPageDoesNotExistException < DitadoException
  end
  
end

Ditado::Core.register_module('wiki', Ditado::WikiWiki)