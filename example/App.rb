require 'femto'
require 'femto/model/model_adapter'

class App < Femto::Base

  @template_dir = File.join(__dir__, 'views')

  layout view: 'layout'

  # Set up database
  Femto::Model::MongoAdapter.connect host: 'localhost', port: 27017, db: 'testing'
  Femto::Model.adapter = Femto::Model::MongoAdapter

  model :user do |m|
    m.field :password
    m.field :username
    m.field :created_at
    m.set_method('confirmed?') { 42 }
  end
  
  get '/', view: 'home' do
    @time = Time.now
    @number = rand 1000
  end

  get '/json' do
    json = {features: {json_rendering: true}}
    render pretty_json: json
  end

  get '/new_user' do
    user = User.new
    user.username = 'username_goes_here'
    user.password = 'password_goes_here'
    render text: 'User created'
  end

  get '/list_users' do
    users = User.find
    results = []
    users.each { |u| results << u.inspect }
    render pretty_json: {users: results}
  end

end