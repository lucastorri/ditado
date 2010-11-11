require 'rubygems'
require 'sinatra/base'

module Ditado
  
  class WebClient < Sinatra::Base
    
    def ditado
      Core.new $DITADO_REPO
    end
    
    get '/' do
      'Hello World!'
    end
    
    get '/issues' do
      'Issues:'
    end
    
    post '/issues' do
      new_issue_id = ditado.issue_add request.body.read
      redirect "/issues/#{new_issue_id}"
    end
    
    before '/issues/:id' do
      halt not_found if !ditado.issue_exists?(params[:id])
    end
    
    get '/issues/:id' do
      ditado.issue_get params[:id]
    end
    
    put '/issues/:id' do
      ditado.issue_edit params[:id], request.body.read
      redirect request.path
    end
    
    delete '/issues/:id' do
      ditado.issue_del params[:id]
    end
    
  end
  
end