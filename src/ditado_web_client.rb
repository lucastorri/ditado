require 'rubygems'
require 'sinatra/base'

module Ditado
  
  class WebClient < Sinatra::Base
    get '/' do
      'Hello World!'
    end
  end
  
end