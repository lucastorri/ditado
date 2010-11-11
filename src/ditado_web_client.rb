require 'rubygems'
require 'sinatra/base'

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
    
    post '/issues' do
      new_issue_id = @ditado.issue_add(params[:content])
      redirect "/issues/#{new_issue_id}"
    end
    
    before '/issues/:id' do
      halt not_found if !@ditado.issue_exists?(params[:id])
    end
    
    get '/issues/:id' do
      @issue = @ditado.issue_get params[:id]
      erb :issue
    end
    
    put '/issues/:id' do
      @ditado.issue_edit params[:id], request.body.read
      redirect request.path
    end
    
    delete '/issues/:id' do
      @ditado.issue_del params[:id]
      redirect '/issues'
    end
    
  end
  
end