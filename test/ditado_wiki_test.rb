require File.expand_path(File.dirname(__FILE__) + '/ditado_test_helper')

describe Ditado::WikiWiki, 'when working with wiki pages' do
  
  before(:each) do
    setup_environment
    @ditado = Ditado::Core.init(DITADO_TEST_ENVIRONMENT)
    @wiki = Ditado::WikiWiki.new(@ditado)
  end
  
  it 'should be a module' do
    @ditado.respond_to?(:wiki_add).should be_false
    @ditado.wiki_add(Ditado::WikiPage.new(WIKI_PAGE_CONTENT_1_TITLE, WIKI_PAGE_CONTENT_1))
    
    Ditado::Core.modules['wiki'].should == Ditado::WikiWiki
  end
  
  context 'and creating pages' do

    it 'should use the slug title of the page as id' do
      page1 = Ditado::WikiPage.new(WIKI_PAGE_CONTENT_1_TITLE, WIKI_PAGE_CONTENT_1)
      @wiki.add(page1).id.should == WIKI_PAGE_CONTENT_1_ID
      page2 = Ditado::WikiPage.new(WIKI_PAGE_CONTENT_2_TITLE, WIKI_PAGE_CONTENT_2)
      @wiki.add(page2).id.should == WIKI_PAGE_CONTENT_2_ID
    end
    
    it 'should not allow the use of invalid titles' do
      [" ", "*-*", " \n", ":)"].each do |invalid_title|
        should_raise_a Ditado::InvalidDitadoWikiPageNameException do
          page = Ditado::WikiPage.new(invalid_title)
          @wiki.add(page)
        end
      end
      
      page = Ditado::WikiPage.new('valid_title')
      @wiki.add(page)
      
    end
    
    it 'should be able do add a new page' do
      File.exists?(WIKI_PAGE_CONTENT_1_FILE).should be_false
      @wiki.add Ditado::WikiPage.new(WIKI_PAGE_CONTENT_1_TITLE, WIKI_PAGE_CONTENT_1)
      File.file?(WIKI_PAGE_CONTENT_1_FILE).should be_true
      open(WIKI_PAGE_CONTENT_1_FILE) do |f|
        f.read.should == WIKI_PAGE_CONTENT_1_RAW
      end
    end
    
    it 'should not be able to override an existent page' do
      FileUtils.touch WIKI_PAGE_CONTENT_1_FILE
      should_raise_a Ditado::DitadoWikiPageAlreadyExistsException do
        @wiki.add Ditado::WikiPage.new(WIKI_PAGE_CONTENT_1_TITLE, WIKI_PAGE_CONTENT_1)
      end
    end
    
  end
  
  context 'and retrieving pages' do
    
    before(:each) do
      @existent_page = @wiki.add Ditado::WikiPage.new(WIKI_PAGE_CONTENT_2_TITLE, WIKI_PAGE_CONTENT_2)
    end
    
    it 'should be able to retrieve the page' do
      page = @wiki.get(@existent_page.id)
      page.title.should == WIKI_PAGE_CONTENT_2_TITLE
      page.content.should == WIKI_PAGE_CONTENT_2
    end
    
    it 'should not be able to retieve inexistent pages' do
      should_raise_a Ditado::DitadoWikiPageDoesNotExistException do
        @wiki.get '00'
      end
    end
    
  end
  
  context 'and removing pages' do
    
    it 'should be able to remove them' do
      File.exists?(WIKI_PAGE_CONTENT_1_FILE).should be_false
      @wiki.add Ditado::WikiPage.new(WIKI_PAGE_CONTENT_1_TITLE, WIKI_PAGE_CONTENT_1)
      File.exists?(WIKI_PAGE_CONTENT_1_FILE).should be_true
      @wiki.get(WIKI_PAGE_CONTENT_1_ID).remove!
      File.exists?(WIKI_PAGE_CONTENT_1_FILE).should be_false
    end
    
    it 'should not be able to remove an inexistent one' do
      should_raise_a Ditado::DitadoWikiPageDoesNotExistException do
        @wiki.del Ditado::WikiPage.new(WIKI_PAGE_CONTENT_1_TITLE, WIKI_PAGE_CONTENT_1, '00')
      end
    end
    
  end

  context 'and editing pages' do
    
    before(:each) do
      @page = @wiki.add Ditado::WikiPage.new(WIKI_PAGE_CONTENT_1_TITLE, WIKI_PAGE_CONTENT_1)
    end
    
    it 'should be able to change the content of a page' do
      @page.content += "\nthat is the new line in content"
      @page.save!
    end

    it 'should be able to change the title of a page' do
      File.exists?(WIKI_PAGE_CONTENT_1_FILE).should be_true
      @page.title = "new title to the page\n"
      @page.save!
      File.exists?(WIKI_PAGE_CONTENT_1_FILE).should be_false
      new_file = "#{DITADO_WIKI_FOLDER}/new-title-to-the-page"
      File.exists?(ISSUE_CONTENT_2_FILE = new_file).should be_true
    end

    it 'should not be able to use an invalid new title' do
      File.exists?(WIKI_PAGE_CONTENT_1_FILE).should be_true
      @page.title = ":)\n"
      should_raise_a Ditado::InvalidDitadoWikiPageNameException do
        @page.save!
      end
    end

    it 'should not be able to edit a inexistent page' do
      page = Ditado::WikiPage.new('00', 'test', '00')
      page.wikiwiki = @wiki
      should_raise_a Ditado::DitadoWikiPageDoesNotExistException do
        page.save!
      end
    end

  end
  
  after(:each) do
    teardown_environment
  end

end