require "sidekiq"
require "metainspector"

class Crawler
  include Sidekiq::Worker
  def perform(id, url)
  	require_relative "../init"
  	dataset = Link.where(:id => id.to_i)

  	return if dataset.empty?
  	
    page = MetaInspector.new("#{url}", 
    	headers: {'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36'},
    	faraday_options: { ssl: { verify: false } })

    if page.content_type.start_with?("text")
		dataset.update({title: page.title, image_url: page.images.best, description: page.description, content_type: page.content_type, updated_at: Time.now})
	elsif page.content_type.start_with?("image")
		dataset.update({title: "Image", image_url: url, content_type: page.content_type, updated_at: Time.now})		
	end
  end
end