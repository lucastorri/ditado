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
    
    def issue_id_valid(id)
      issue_content = nil
      begin
        issue_content = ditado.issue_get id
      rescue IssueIdNotExistentException => e
        status 404
      end
      !issue_content.nil?
    end
    
    get '/issues/:id' do
      return unless issue_id_valid params[:id]
      ditado.issue_get params[:id]
    end
    
    delete '/issues/:id' do
      return unless issue_id_valid params[:id]
      ditado.issue_del params[:id]
    end
    
  end
  
end