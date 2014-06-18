require 'femto/model/mongo_adapter'

module Femto

  module Model

    class << self
      attr_accessor :adapter

      def symbolize_keys(hash)
        hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      end

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
      class << model_class
        def find(query={})
          Model.adapter.find(self, query)
        end
        alias_method :where, :find
        def create(field={})
          model = self.new fields
          model.save
          model
        end
        def all
          self.find
        end
      end

      model_class.module_eval do
        define_method 'save' do
          Model.adapter.update self
        end
        alias_method :update, :save

        define_method('remove') { Model.adapter.remove self }
        alias_method :delete, :remove

        define_method 'to_hash' do
          result = {}
          self.class.model_attrs[:fields].each do |f|
            val = send f
            result[f] = val if val
          end
          result
        end
        alias_method :to_h, :to_hash

        define_method 'initialize' do |fields={}|
          fields.each_pair do |key, val|
            next unless self.class.model_attrs[:fields].include? key
            send key.to_s + '=', val
          end
        end

        define_method 'validate' do
          m_attrs = self.class.model_attrs
          errs = {}
          m_attrs[:fields].each do |field|
            val = send field
            validations = m_attrs[:validations][field]
            next unless validations
            validations.each do |v|
              errs[field] = val if v.call(val) == false
            end
          end
          raise ValidationException.new("The following fields were not acceptable: #{errs}") unless errs.empty?
        end
  
        define_method '[]' do |field|
          instance_variable_get "@#{field.to_s}"
        end
      end

      # Model attributes (fields, storage, etc...)
      class << model_class
        attr_accessor :model_attrs
      end
      storage = model_creator.storage_name ? model_creator.storage_name.to_s : name + 's'
      model_class.model_attrs = {
          fields: model_creator.fields,
          storage_name: storage,
          validations: model_creator.validations,
          name: name
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
      attr_accessor :validations

      def initialize
        @fields = []
        @defaults = {}
        @types = {}
        @custom_methods = {}
        @validations = {}
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

      # The validation block should return a boolean value
      # signifying whether or not the field's value is acceptable
      def validate(field, &block)
        @validations[field] ||= []
        @validations[field] << block
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

    class ModelException < Exception
      def initialize(msg)
        super msg
      end
    end

    class ValidationException < ModelException
    end

  end

end
