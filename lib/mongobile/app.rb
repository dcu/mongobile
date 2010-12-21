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

    delete "/database/:id/:collection/" do
      db(params[:id]).drop_collection(col.name)
      redirect "/database/#{params[:id]}"
    end

    delete "/database/:id" do
      connection.drop_database(params[:id])
      redirect "/"
    end

    post "/database/:id/repair" do
      @database = db(params[:id])
      Thread.start do
        @database.command({:repairDatabase => 1})
        $stderr.puts "FINISHED!!!"
        puts "FINISHED!!!"
      end
      redirect "/database/#{params[:id]}"
    end

    private
    def error_not_found
      status 404
    end
  end
end
