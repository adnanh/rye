require "sidekiq"
require "metainspector"

class Crawler
  include Sidekiq::Worker
  def perform(id, url)
  	require_relative "../init"
  	
    page = MetaInspector.new("#{url}", :headers => {'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36'})
    Link.where(:id => id.to_i).update({title: page.title, image_url: page.images.best, description: page.description})
  end
end