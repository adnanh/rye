require "sinatra"
require "tilt/erubis"
require "uri"
require_relative "init"
require_relative "workers/crawler"

get "/" do
  total = Link.count
  links_per_page = CONFIG["settings"]["links_per_page"]
  page_count = (total.to_f/links_per_page).ceil
  
  page = 1
  page = [[1, params[:page].to_i].max, page_count].min if params.key? "page"

  offset = (page-1) * links_per_page

  links = Link.order(Sequel.desc(:id)).limit(links_per_page, offset)

  erb :index, locals: {links: links, total: total, page: page, page_count: page_count}
end

get "/link/new" do
  erb :new_link
end

post "/link" do
  if params[:password] == CONFIG["settings"]["password"]
    begin
      url = URI.parse(params[:url])
      url_string = url.to_s

      now = Time.now
      id = Link.insert({url: url_string, content_type: "parsing", created_at: now, updated_at: now})
      
      Crawler.perform_async(id, url_string)
    rescue URI::InvalidURIError
    end
  end

  redirect "/"
end

get "/delete/:id" do
  erb :delete, locals: {id: params[:id].to_i}
end

post "/delete/:id" do
  if params[:password] == CONFIG["settings"]["password"]
    Link.where(:id => params[:id].to_i).delete
  end

  redirect "/"
end