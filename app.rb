require "sinatra"
require "metainspector"
require_relative "init"

get "/" do
  page = 1
  page = [1, params[:page].to_i].max if params.key? "page"

  links_per_page = CONFIG["settings"]["links_per_page"]
  offset = (page-1) * links_per_page

  links = Link.limit(links_per_page, offset)

  erb :index, locals: {links: links, total: Link.count, page: page}
end

post "/link" do
  content_type :json

  if params[:password] == CONFIG["settings"]["password"]
    page = MetaInspector.new("#{params[:url]}", :headers => {'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36'})
    Link.insert({title: page.title, image_url: page.images.best, description: page.description, url: page.url})
  end
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