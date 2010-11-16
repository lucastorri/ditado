require File.expand_path(File.dirname(__FILE__) + '/ditado_test_helper')

describe Ditado::IssueTracker, 'when working with issues' do
  
  before(:each) do
    setup_environment
    @ditado = Ditado::Core.init DITADO_TEST_ENVIRONMENT
    @tracker = Ditado::IssueTracker.new(@ditado)
  end
  
  it 'should be a module' do
    @ditado.respond_to?(:issue_add).should be_false
    @ditado.issue_add(ISSUE_CONTENT_1)
    
    issues_module = Ditado::Core.modules['issue'].should == Ditado::IssueTracker
  end
  
  context 'and creating issues' do
    
    before(:each) do
      @tracker.stub!(:diffstamp).and_return(TIME_NOW)
    end
    
    it 'should set the issue id as the SHA1 hash from the issue content plus the current time' do
      @tracker.add(ISSUE_CONTENT_1).should == ISSUE_CONTENT_1_SHA1
      @tracker.add(ISSUE_CONTENT_2).should == ISSUE_CONTENT_2_SHA1
    end
    
    it 'should be able to add and persist new issues' do
      issue_id_1 = @tracker.add ISSUE_CONTENT_1
      issue_id_2 = @tracker.add ISSUE_CONTENT_2

      open(ISSUE_CONTENT_1_FILE) do |f|
        f.read.should == ISSUE_CONTENT_1
      end

      open(ISSUE_CONTENT_2_FILE) do |f|
        f.read.should == ISSUE_CONTENT_2
      end    
    end
    
    it 'should not be able to create issues with same key' do
      @tracker.add(ISSUE_CONTENT_1).should == ISSUE_CONTENT_1_SHA1
      content_before = ''
      open(ISSUE_CONTENT_1_FILE) do |f|
        content_before = f.read
      end
      
      should_raise_a  Ditado::IssueIDAlreadyExistentException do
        @tracker.add(ISSUE_CONTENT_1)
      end
      open(ISSUE_CONTENT_1_FILE) do |f|
        f.read.should == content_before
      end
    end
    
    it 'should be able to identify if a issue exists' do
      issue_id_1 = @tracker.add(ISSUE_CONTENT_1)
      @tracker.exists?(issue_id_1).should be_true
      
      @tracker.exists?('00').should be_false
    end
    
  end
  
  context 'and retrieving issues' do
  
    it 'should be able to retrieve existent issues' do
      issue_id_1 = @tracker.add ISSUE_CONTENT_1
      issue_id_2 = @tracker.add ISSUE_CONTENT_2
    
      @tracker.get(issue_id_1).should == ISSUE_CONTENT_1
      @tracker.get(issue_id_2).should == ISSUE_CONTENT_2
    end
    
    it 'should not retrieve anything when the issue does not exist' do
      should_raise_a Ditado::IssueIdNotExistentException do
        @tracker.get('00')
      end
    end
    
    it 'should be able to list all existent issues' do
      @tracker.list.empty?.should be_true
       
      issue_id_1 = @tracker.add ISSUE_CONTENT_1
      @tracker.list.should == [issue_id_1]
       
      issue_id_2 = @tracker.add ISSUE_CONTENT_2
      (@tracker.list - [issue_id_1, issue_id_2]).any?.should be_false
    end
  
  end
  
  context 'and removing issues' do
  
    it 'should return exception when the issue does not exist' do
      should_raise_a Ditado::IssueIdNotExistentException do
        @tracker.del('00')
      end
    end
  
    it 'should be able to remove an existent issue' do
      issue_id_1 = @tracker.add ISSUE_CONTENT_1
      @tracker.del(issue_id_1)
      File.exists?(ISSUE_CONTENT_1_FILE).should be_false
    end
  
  end
  
  context 'and editing issues' do
    
    NEW_ISSUE_CONTENT_1 = 'When are you going to fix this?'
    
    before(:each) do
      @tracker.stub!(:diffstamp).and_return(TIME_NOW)
      @tracker.add(ISSUE_CONTENT_1)
    end
    
    it 'should be able to change the content of a issue' do
      content_before = ''
      open(ISSUE_CONTENT_1_FILE) do |f|
        content_before = f.read
      end
      
      @tracker.edit(ISSUE_CONTENT_1_SHA1, NEW_ISSUE_CONTENT_1)
      open(ISSUE_CONTENT_1_FILE) do |f|
        f.read.should == NEW_ISSUE_CONTENT_1
      end
    end
    
    it 'should not be able to edit an inexistent issue' do
      should_raise_a Ditado::IssueIdNotExistentException do
        @tracker.edit('00', NEW_ISSUE_CONTENT_1)
      end
    end
    
  end
  
  after(:each) do
    teardown_environment
  end
  
end