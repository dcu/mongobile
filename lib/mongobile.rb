require 'rubygems'
require 'bundler'
require 'bundler/setup'

require 'benchmark'
require 'sinatra'
require 'haml'
require 'bson'
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

