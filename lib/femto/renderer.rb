require 'json'

module Femto

  module Renderer

    @renderers = {}

    def self.render(type, content)
      renderer = @renderers[type]
      raise RendererNotFoundException.new('No renderer for type ' + type.inspect) unless renderer
      renderer.call content
    end

    def self.renderer(type, &block)
      @renderers[type] = block
    end

    renderer(:json) { |c| ['application/json', c.to_json] }
    renderer(:pretty_json) { |c| ['application/json', JSON.pretty_generate(c)] }
    renderer(:text) { |c| ['text/plain', c.to_s] }

    class RendererNotFoundException < Exception
      def initialize(reason)
        super reason
      end
    end

  end

end