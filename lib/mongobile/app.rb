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
      db.drop_collection(col.name)
      ok
    end

    get "/:database/:collection/" do
      {
        "db_name" => [db.name, col.name].join("/"),
        "doc_count" => col.count,
        "disk_size" => 123
      }.to_json
    end

    post "/database/:id/:collection/repair" do
      Thread.start do
        db.command({:repairDatabase => 1})
      end
      status 202
    end

    private
    def error_not_found
      status 404
    end
  end
end
