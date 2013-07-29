require 'bundler/setup'
require 'compass'
require 'sinatra'
require 'haml'
require 'redcarpet'
require 'mongo'
require 'mongoid'

configure do
  Mongoid.load!('mongoid.yml')
end

# Model for blog posts
class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :body, type: String
end

class App < Sinatra::Base  
  # setup compass
  configure do
    set :haml, {:format => :html5, :escape_html => true}
    set :scss, {:style => :compact, :debug_info => false}
    Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
  end

  get '/stylesheets/:name.css' do
    content_type 'text/css', :charset => 'utf-8'
    scss(:'stylesheets/#{params[:name]}' ) 
  end

  # basic routes
  get('/') { haml :index }
  get('/sample') { haml :sample }
  get('/blog') { haml :blog }

  # blog routes
  get '/blog' do
    @posts = Post.all.descending(:published_on).to_a
    haml :blog
  end

  get '/blog/new' do
    haml :new
  end

  post '/blog/new' do
    @post = Post.create(params[:post])
    redirect '/blog'
  end

  get '/blog/edit/:id' do |id|
    @post = Post.find(id)
    haml :edit, :locals => { :body => @post.body}
  end

  post '/blog/update/:id' do |id|
    @post = Post.find(id)
    @post.update_attributes(params[:post])
    redirect '/blog'
  end

  post '/blog/del/:id' do |id|
    @post = Post.find(id)
    @post.delete
    redirect '/blog'
  end
end