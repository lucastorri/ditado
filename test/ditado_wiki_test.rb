require File.expand_path(File.dirname(__FILE__) + '/ditado_test_helper')

describe Ditado::WikiWiki, 'when working with wiki pages' do
  
  before(:each) do
    setup_environment
    @ditado = Ditado::Core.init(DITADO_TEST_ENVIRONMENT)
    @wiki = Ditado::WikiWiki.new(@ditado)
  end
  
  it 'should be a module' do
    @ditado.respond_to?(:wiki_add).should be_false
    @ditado.issue_add(WIKI_PAGE_CONTENT_1)
    
    Ditado::Core.modules['wiki'].should == Ditado::WikiWiki
  end
  
  context 'and creating pages' do

    it 'should use the slug title of the page as id' do
      @wiki.add(WIKI_PAGE_CONTENT_1).should == WIKI_PAGE_CONTENT_1_ID
      @wiki.add(WIKI_PAGE_CONTENT_2).should == WIKI_PAGE_CONTENT_2_ID
    end
    
    it 'should use the first line of the new page contents as its title' do
      should_raise_a Ditado::InvalidDitadoWikiPageNameException do
        @wiki.add(" ")
      end
      
      should_raise_a Ditado::InvalidDitadoWikiPageNameException do
        @wiki.add('*-*')
      end
      
      should_raise_a Ditado::InvalidDitadoWikiPageNameException do
        @wiki.add(" \n")
      end
      
      should_raise_a Ditado::InvalidDitadoWikiPageNameException do
        @wiki.add(":)")
      end
      
      @wiki.add('a').should == 'a'
    end
    
    it 'should be able do add a new page' do
      File.exists?(WIKI_PAGE_CONTENT_1_FILE).should be_false
      @wiki.add WIKI_PAGE_CONTENT_1
      File.file?(WIKI_PAGE_CONTENT_1_FILE).should be_true
      open(WIKI_PAGE_CONTENT_1_FILE) do |f|
        f.read.should == WIKI_PAGE_CONTENT_1
      end
    end
    
    it 'should not be able to override an existent page' do
      FileUtils.touch WIKI_PAGE_CONTENT_1_FILE
      should_raise_a Ditado::DitadoWikiPageAlreadyExistsException do
        @wiki.add WIKI_PAGE_CONTENT_1
      end
    end
    
  end
  
  context 'and retrieving pages' do
    
    before(:each) do
      @existent_page_id = @wiki.add WIKI_PAGE_CONTENT_2
    end
    
    it 'should be able to retrieve the page raw content' do
      @wiki.get(@existent_page_id).should == WIKI_PAGE_CONTENT_2
    end
    
    it 'should be able to retieve the html source from the textile content with the first line as a h1' do
      @wiki.textile(@existent_page_id).should == WIKI_PAGE_CONTENT_2_AS_TEXTILE
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
      @wiki.add WIKI_PAGE_CONTENT_1
      File.exists?(WIKI_PAGE_CONTENT_1_FILE).should be_true
      @wiki.del WIKI_PAGE_CONTENT_1_ID
      File.exists?(WIKI_PAGE_CONTENT_1_FILE).should be_false
    end
    
    it 'should not be able to remove an inexistent one' do
      should_raise_a Ditado::DitadoWikiPageDoesNotExistException do
        @wiki.del '00'
      end
    end
    
  end
  
  context 'and editing pages' do
    
    before(:each) do
      @wiki.add WIKI_PAGE_CONTENT_1
    end
    
    it 'should be able to change the content of a page' do
      new_content = WIKI_PAGE_CONTENT_1 + 'that is the new line'
      @wiki.edit(WIKI_PAGE_CONTENT_1_ID, new_content).should == WIKI_PAGE_CONTENT_1_ID
      open(WIKI_PAGE_CONTENT_1_FILE) do |f|
        f.read.should == new_content
      end
    end
    
    it 'should be able to change the title of a page' do
      File.exists?(WIKI_PAGE_CONTENT_1_FILE).should be_true
      new_content = "new title to the page\n" + WIKI_PAGE_CONTENT_1
      @wiki.edit WIKI_PAGE_CONTENT_1_ID, new_content
      File.exists?(WIKI_PAGE_CONTENT_1_FILE).should be_false
      new_file = "#{DITADO_WIKI_FOLDER}/new-title-to-the-page"
      File.exists?(ISSUE_CONTENT_2_FILE = new_file).should be_true
      open(new_file) do |f|
        f.read.should == new_content
      end
    end
    
    it 'should not be able to use an invalid new title' do
      File.exists?(WIKI_PAGE_CONTENT_1_FILE).should be_true
      new_content = ":)\n" + WIKI_PAGE_CONTENT_1
      should_raise_a Ditado::InvalidDitadoWikiPageNameException do
        @wiki.edit WIKI_PAGE_CONTENT_1_ID, new_content
      end
    end
    
    it 'should not be able to edit a inexistent page' do
      should_raise_a Ditado::DitadoWikiPageDoesNotExistException do
        @wiki.edit '00', WIKI_PAGE_CONTENT_1
      end
    end
    
  end
  
  after(:each) do
    teardown_environment
  end
  
end