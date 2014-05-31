require 'femto/model/mongo_adapter'

module Femto

  module Model
    class Adapter
      class << self
        attr_accessor :adapter

        def find(cls, args)
          @adapter.find(cls, args)
        end

        def update(model)
          @adapter.update model
        end

        alias_method :save, :update
      end
    end
  end
end