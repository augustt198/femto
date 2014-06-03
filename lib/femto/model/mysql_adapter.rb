require 'mysql2'

module Femto
  module Model
    class MysqlAdapter
      class << self

        attr_accessor :client

        def connect(options)
          @client = Mysql::Client.new(options)
        end

        def find(cls, query)
          raise NotImplementedError.new
        end

        def get_table(cls)
          cls.model_attrs[:storage_name]
        end

      end
    end
  end
end