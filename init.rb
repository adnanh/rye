require "yaml"
require "sequel"
require "tilt/erubis"

CONFIG = YAML.load_file("config.yaml")

DB = Sequel.connect(CONFIG["database"]["connection_string"])

unless DB.table_exists?(:links)
  DB.create_table :links do
    primary_key :id
    String :url
    column :title, :text
    column :description, :text
    String :image_url
  end
end

class Link < Sequel::Model(:links)
end