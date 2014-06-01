require 'mongo'

module Femto
  module Model
    class MongoAdapter
      class << self

        attr_accessor :client
        attr_accessor :db

        def connect(options=nil)
          if options
            @client = Mongo::Connection.new(options[:host], options[:port])
            @db = @client[options[:db]]
          else
            @client = Mongo::Connection.new
            @db = @client['test']
          end
        end

        def to_hash(model)
          result = {}
          model.class.model_attrs[:fields].each do |f|
            var = model.send f
            result[f] = var if var
          end
          result
        end

        def find(cls, query)
          results = []
          get_coll(cls).find(query).each do |res|
            results << cls.new(symbolize_keys(res))
          end
          results
        end

        def update(model)
          coll = get_coll model.class
          if model.id
            coll.update({:_id => model.id}, model.to_hash)
          else
            model.id = coll.insert model.to_hash
          end
        end

        def delete(model)
          coll = get_coll model.class
          if model.id
            coll.remove(:_id => model.id)
          end
        end

        def get_coll(cls)
          @db[cls.model_attrs[:storage_name]]
        end

        def symbolize_keys(hash)
          hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
        end

      end

    end
  end
end

