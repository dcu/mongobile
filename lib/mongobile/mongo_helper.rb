module Mongobile
  module MongoHelper
    def connection
      @connection ||= begin
        host = ARGV[0] || "127.0.0.1"
        port = ARGV[1] || 27017
        Mongo::Connection.new(host, port)
      end
    end

    def db(d=nil)
      connection.db(d || params[:id]) rescue nil
    end

    def get_key(key)
      $stderr.puts "GetKey : #{key}"
      return nil if key.nil?

      key.gsub!('"', '')
      if key =~ /^[0-9]+$/
        return key.to_i
      else
        return BSON::ObjectID.from_string(key) rescue key
      end
    end

    def find_doc(id, collection)
      collection.find_one({ "_id" => get_key(id) }) || collection.find_one({ "_id" => id.to_s })
    end

    def query_options
      options = {}
      options[:limit] = params[:limit].nil? ? 25 : params[:limit].to_i
      options[:sort] = [["_id", (params[:descending] == "true" ? 'descending' : 'ascending')]]
      options[:skip] = params[:skip].nil? ? 0 : params[:skip].to_i

      options
    end

    def document_list(collection)
      collection.find({}, query_options)
    end

    def file_size(database)
      "%0.2f MB" % (database.stats["fileSize"] / 1024**2)
    end

    def normalize_stats(stats)
      r={}
      stats.each do |k,v|
        if k =~ /size/i
          if v.kind_of?(Hash)
            v.each do |ki,vi|
              v[ki]="%0.2f MB" % (vi.to_f/1024**2)
            end
            r[k] = v
          else
            r[k]="%0.2f MB" % (v.to_f/1024**2)
          end
        else
          r[k]=v
        end
      end
      r
    end

    def server_status
      db("test").command(:serverStatus => 1)
    end

    def ops_per_second
      counters = []
      time_list = []
      delays = []

      4.times do
        delays << Benchmark.realtime do
          counters << server_status["opcounters"]
        end
        time_list << Time.now

        sleep 1
      end

      ops_average = {"query" => 0, "insert" => 0, "command" => 0, "update" => 0, "getmore" => 0, "delete" => 0}
      time_average = 0
      1.upto(counters.size-1) do |index|
        ops_average.keys.each do |k|
          ops_average[k] += (counters[index][k] - counters[index-1][k])
        end
        time_average += (time_list[index] - time_list[index-1]) - delays[index]
      end

      time_average /= counters.size

      ops_average.each do |k,v|
        ops_average[k] = ((ops_average[k] / counters.size)/time_average).round
      end

      ops_average
    end
  end
end
