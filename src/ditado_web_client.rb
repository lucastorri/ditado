require 'rubygems'
require 'sinatra/base'

module Ditado
  
  class DitadoWebClient < Sinatra::Base
    get '/' do
      'Hello World!'
    end
  end
  
end