require 'rubygems'
require 'sinatra/base'

module Ditado
  
  class WebClient < Sinatra::Base
    
    get '/' do
      'Hello World!'
    end
    
    get '/issues' do
      'Issues:'
    end
    
    get '/issues/:id' do
      ditado = Core.new $DITADO_REPO
      ditado.issue_get params[:id]
    end
    
  end
  
end