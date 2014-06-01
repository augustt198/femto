require 'femto/model/mongo_adapter'

module Femto

  module Model

    class << self
      attr_accessor :adapter
    end

    def self.create_model(name, &block)
      class_name = camelize name
      begin
        Object.const_get class_name
        return # Class already exists
      rescue NameError
        # ignored
      end
      model_creator = ModelCreator.new
      block.call model_creator

      # Create class
      model_class = Class.new &model_creator.class_opts
      Object.const_set(class_name, model_class)

      # Create accessors for attributes
      model_creator.fields.each do |a|
        model_class.module_eval { attr_accessor a }
      end
      model_class.module_eval { attr_accessor :id }

      # Add custom methods
      model_creator.custom_methods.each_pair do |method_name, method_block|
        model_class.module_eval { define_method method_name, &method_block }
      end

      # Add model methods
      model_class.define_singleton_method 'find' do |query={}|
        Model.adapter.find(model_class, query)
      end
      model_class.define_singleton_method 'where' do |query={}|
        Model.adapter.find(model_class, query)
      end
      model_class.define_singleton_method 'create' do |fields={}|
        model = model_class.new fields
        model.save
        model
      end
      model_class.define_singleton_method 'all' do
        model_class.find
      end

      model_class.module_eval do
        define_method 'update' do
          Model.adapter.update self
        end

        define_method 'save' do
          Model.adapter.update self
        end

        define_method('remove') { Model.adapter.remove self }
        define_method('delete') { Model.adapter.remove self }

        define_method 'to_hash' do
          result = {}
          self.class.model_attrs[:fields].each do |f|
            val = send f
            result[f] = val if val
          end
          result
        end

        define_method 'initialize' do |fields={}|
          fields.each_pair do |key, val|
            next unless self.class.model_attrs[:fields].include? key
            send key.to_s + '=', val
          end
        end
      end

      # Model attributes (fields, storage, etc...)
      class << model_class
        attr_accessor :model_attrs
      end
      storage = model_creator.storage_name ? model_creator.storage_name.to_s : name + 's'
      model_class.model_attrs = {
          fields: model_creator.fields,
          storage_name: storage
      }

      # Create method for getting defined fields
      model_class.define_singleton_method('fields') { model_creator.fields }
    end

    class ModelCreator
      attr_accessor :fields
      attr_accessor :defaults
      attr_accessor :types
      attr_accessor :class_opts
      attr_accessor :custom_methods
      attr_accessor :storage_name

      def initialize
        @fields = []
        @defaults = {}
        @types = {}
        @custom_methods = {}
      end

      def field(name, options={})
        return unless name
        fields << name
        if options[:default]
          defaults[name]
        end
      end

      def class_options(&block)
        @class_opts = block
      end

      def set_method(name, &block)
        custom_methods[name] = block
      end

      def storage(name)
        @storage_name = name
      end
    end

    # Taken from http://infovore.org/archives/2006/08/11/writing-your-own-camelizer-in-ruby/
    def self.camelize(snake_case, first_upcase=true)
      if first_upcase
        snake_case.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
      else
        snake_case.first + camelize(snake_case)[1..-1]
      end
    end

  end

end