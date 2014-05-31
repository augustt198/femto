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

        def create_from_hash(cls, hash={})
          obj = cls.new
          cls.fields.each do |f|
            val = hash[f.to_s]
            obj.send(f.to_s + '=', val) if val
          end
          obj.send('id=', hash['_id']) if hash['_id']
          obj
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
            results << create_from_hash(cls, res)
          end
          results
        end

        def update(model)
          if model.id
            get_coll(model.class).update({:_id => model.id}, to_hash(model))
          else
            get_coll(model.class).insert to_hash(model)
          end
        end

        def get_coll(cls)
          @db[cls.model_attrs[:storage_name]]
        end
      end

    end
  end
end

