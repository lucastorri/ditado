require 'rubygems'
require 'sinatra/base'
require 'hpricot'

module Ditado
  
  class WebClient < Sinatra::Base
    
    use Rack::MethodOverride
    
    set :views, File.expand_path(File.dirname(__FILE__) + '/../res/views')
    set :public, File.expand_path(File.dirname(__FILE__) + '/../res/static')
    
    before do
      @ditado = ditado
    end
    
    def ditado
      Core.new $DITADO_REPO
    end
    
    get '/' do
      erb :index
    end
    
    get '/issues' do
      erb :issues
    end
    
    get '/issues_new' do
      erb :new
    end
    
    post '/issues' do
      halt bad_request if params.empty?
      new_issue_id = @ditado.issue_add(to_xml(params))
      redirect "/issues/#{new_issue_id}"
    end
    
    before '/issues/:id' do
      halt not_found if !@ditado.issue_exists?(params[:id])
    end
    
    get '/issues/:id' do
      @issue = to_hash @ditado.issue_get(params[:id])
      erb :issue
    end
    
    put '/issues/:id' do
      id = params[:id]
      params.delete :id
      @ditado.issue_edit id, to_xml(params)
      redirect request.path
    end
    
    delete '/issues/:id' do
      @ditado.issue_del params[:id]
      redirect '/issues'
    end
    
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