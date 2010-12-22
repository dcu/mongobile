module Mongobile
  class App < Sinatra::Base
    include Mongobile::MongoHelper

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end

    set :public, File.expand_path("../../../public", __FILE__)
    set :views, File.expand_path("../../../lib/mongobile/views", __FILE__)

    before do
    end

    get "/" do
      @databases = connection.database_names
      haml :index
    end

    get "/status" do
      haml :status
    end

    get "/database/:id" do
      @database = db(params[:id])
      @collections = @database.collections
      haml :"database/show"
    end

    get "/database/:id/:collection" do
      @database = db(params[:id])
      @collection = @database.collection(params[:collection])
      haml :"database/collection"
    end

    put "/database/:id/:collection" do
      db.create_collection(params[:collection])
      status 201
    end

    post "/database/:id/:collection/delete" do
      @database = db(params[:id])
      @database.drop_collection(params[:collection])

      redirect "/database/#{params[:id]}"
    end

    post "/database/:id/delete" do
      connection.drop_database(params[:id])
      redirect "/"
    end

    post "/database/:id/repair" do
      @database = db(params[:id])
      Thread.start do
        @database.command({:repairDatabase => 1})
      end
      redirect "/database/#{params[:id]}"
    end

    def humanize(v)
      if v.kind_of?(Hash)
        v.inspect
      elsif v.kind_of?(Array)
        v.inspect
      elsif v.kind_of?(Time)
        v.strftime("%d %B %Y %H:%M:%S")
      else
        v
      end
    end

    private
    def error_not_found
      status 404
    end
  end
end
