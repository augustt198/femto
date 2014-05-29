require 'femto'

class App < Femto::Base

  @template_dir = File.join(__dir__, 'views')

  layout view: 'layout'

  get '/', view: 'home' do
    @time = Time.now
    @number = rand 1000
  end

  get '/json' do
    json = {features: {json_rendering: true}}
    render json: JSON.pretty_generate(json)
  end

end