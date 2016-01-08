require "sidekiq"
require "metainspector"
require "http"

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
      if CONFIG.key? "pinterest"
        HTTP.post "https://api.pinterest.com/v1/pins/", params: { access_token: CONFIG["pinterest"]["token"] }, form: { board: CONFIG["pinterest"]["board_id"], note: "#{page.title} #{page.description}", link: url, image_url: page.images.best }
      end
    elsif page.content_type.start_with?("image")
      dataset.update({title: "Image", image_url: url, content_type: page.content_type, updated_at: Time.now})		
      if CONFIG.key? "pinterest"
        HTTP.post "https://api.pinterest.com/v1/pins/", params: { access_token: CONFIG["pinterest"]["token"] }, form: { board: CONFIG["pinterest"]["board_id"], note: "Image", link: url, image_url: url }
      end
    end
  end
end
