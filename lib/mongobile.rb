require 'bundler/setup'
Bundler.setup

require 'sinatra'
require 'haml'
require 'mongo'

require 'net/http'
require 'uri'
require 'cgi'

require 'mongobile/mongo_helper'
require 'mongobile/app'

module Mongobile
  def self.app
    Mongobile::App
  end
end

