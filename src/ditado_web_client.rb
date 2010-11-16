require 'rubygems'
require 'sinatra/base'
require 'hpricot'

module Ditado
  
  SERVER_SCOPE = 'localhost'
  SERVER_PORT = 9317
  
  class UI
    
    def start
      Ditado::WebClient.run! :host => SERVER_SCOPE, :port => SERVER_PORT
    end
    
  end
  
  class WebClient < Sinatra::Base
    
    use Rack::MethodOverride
    
    set :views, File.expand_path(File.dirname(__FILE__) + '/../res/views')
    set :public, File.expand_path(File.dirname(__FILE__) + '/../res/static')
    
    before do
      @ditado = ditado
      params.delete '_method'
    end
    
    def ditado
      Core.new $DITADO_REPO
    end
    
    get '/?' do
      erb :index
    end
    
    get '/issues/?' do
      @issues = @ditado.issue_list.inject([]) do |issues, issue_id|
        issues << [issue_id, to_hash(@ditado.issue_get(issue_id))[:title]]
      end
      erb :issues
    end
    
    get '/issues_new' do
      erb :new
    end
    
    post '/issues/?' do
      halt bad_request if params.empty?
      new_issue_id = @ditado.issue_add(to_xml(params))
      redirect "/issues/#{new_issue_id}"
    end
    
    before '/issues/:id' do
      halt not_found if !@ditado.issue_exists?(params[:id])
      @id = params[:id]
      params.delete :id
    end
    
    get '/issues/:id' do
      @issue = to_hash @ditado.issue_get(@id)
      erb :issue
    end
    
    put '/issues/:id' do
      @ditado.issue_edit @id, to_xml(params)
      redirect request.path
    end
    
    delete '/issues/:id' do
      @ditado.issue_del @id
      redirect '/issues'
    end
    
    #sinatra precondition, 1 line rescue
    get '/wiki/?' do
      redirect '/wiki/index'
    end
    
    get '/wiki_new' do
      erb :wiki, :locals => { :text => '', :title =>  'New page', :raw => '' }
    end
    
    before '/wiki/:page' do
      @page = params[:page]
      halt not_found unless @ditado.wiki_exists?(@page)
    end
    
    get '/wiki/:page' do
      page_content = @ditado.wiki_textile(@page)
      page_content.split("\n")[0] =~ /<h1>(.*)<\/h1>/
      if params.key? 'edit' then
        erb :wiki, :locals => { :text => page_content, :title =>  $1, :raw => @ditado.wiki_get(@page) }
      else
        erb :wiki, :locals => { :text => page_content, :title =>  $1 }
      end
    end
    
    post '/wiki/?' do
      page = @ditado.wiki_add params[:content]
      redirect "/wiki/#{page}"
    end
    
    put '/wiki/:page' do
      page = @ditado.wiki_edit(@page, params[:content]) unless @page == 'index' and params[:content].split("\n")[0] == 'index'
      redirect "/wiki/#{page}"
    end
    
    delete '/wiki/:page' do
      @ditado.wiki_del @page unless @page == 'index'
      redirect '/wiki' 
    end
    
    private
    
    def to_xml(params)
      s = "<issue>\n"
      params.each do |key, value|
        s += "<#{key}>#{value}</#{key}>\n"
      end
      s += '</issue>'
    end
    
    def to_hash(xml)
      Hpricot(xml).search('/issue/*').to_a.inject({}) { |content, elem| content[elem.name.to_sym] = elem.to_plain_text; content }
    end
    
  end
  
end

Ditado::Core.register_module('ui', Ditado::UI)