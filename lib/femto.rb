require 'femto/version'
require 'femto/renderer'
require 'tilt'
require 'rack'
require 'json'

module Femto

  class Base
    class << self

      attr_accessor :request, :response, :env, :routes, :template_dir,
                    :render, :content_type, :layout, :layout_block

      # set up methods
      %w(get post patch put delete).each do |http_verb|
        define_method http_verb do |path, options={}, &block|
          set_route http_verb, path, options, block
        end
      end

      def layout(options={}, &block)
        if options[:template]
          @layout = resolve_template options[:template]
        elsif options[:view]
          @layout = resolve_template options[:view]
        end
        @layout_block = block
      end

      def set_route(verb, path, options, block)
        @routes = {} unless @routes
        @routes[verb] = [] unless @routes[verb]
        @routes[verb] << [path, options, block]
      end

      def handle_request
        catch :stop do
          verb = request.request_method.downcase
          request_path = request.path_info
          routes = @routes[verb]
          if routes
            routes.each do |group|
              path = group[0]
              options = group[1]
              block = group[2]
              if request_path == path
                instance_eval(&block)
                if options[:template]
                  render options[:template]
                elsif options[:view]
                  render options[:view]
                end
                if @layout and @content_type == 'text/html'
                  if @layout_block
                    @layout_block.call
                  end
                  @render = render_template(@layout) { @render }
                end
                if @render == nil
                  raise TemplateMissingException.new
                end
                response.write @render
                response['Content-Type'] = content_type
                return
              end
            end
          end
          stop
        end
      end

      def render(options)
        if options.is_a? Hash
          pair = options.to_a[0]
          type = pair[0]
          content = pair[1]
          render_pair = Femto::Renderer.render(type, content)
          @content_type = render_pair[0]
          @render = render_pair[1]
        elsif options.is_a? String
          @render = render_template(resolve_template(options))
        end
      end

      def resolve_template(file)
        Dir[File.join(@template_dir, file + '.*')][0]
      end

      def render_template(template, &block)
        @content_type = 'text/html'
        Tilt.new(template).render self, {}, &block
      end

      def stop
        throw :stop
      end

      def builder
        @builder = Rack::Builder.new unless @builder
        @builder
      end

      def call(env)
        dup.call! env
      end

      def call!(env)
        env['PATH_INFO'] = '/' if env['PATH_INFO'].empty?
        @request = Rack::Request.new env
        @response = Rack::Response.new
        @render = nil
        @content_type = nil
        @env = env
        handle_request
        @response.finish
      end

    end

    class TemplateMissingException < Exception
      def initialize
        super 'No template to be rendered was found'
      end
    end

  end

  class RequestException < Exception
    attr_reader :code
    attr_reader :message
    def initialize(code, msg)
      super "#{code}: #{msg}"
      @code = code
      @message = msg
    end
  end

end
