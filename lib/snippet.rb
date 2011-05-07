require 'dm-core'

class Snippet
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String, :required => true
  property :content,    Text, :required => true, :lazy => false
  property :votes,      Integer, :required => true, :default => 0
  property :public,     Boolean, :default => true
  property :url,        String, :required => true, :unique_index => true
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :user
  has n, :snippetvote
  has n, :snippettag

  def save_tags tagtext
    tag_names = tagtext.split(/[, ]+/).map{ |t| t.downcase }
    tag_names.each do |tagtext|
      Snippettag.first_or_create(
        {:name => tagtext, :snippet => self},
        {:name => tagtext, :snippet => self},
      )
    end
    snippettag.each{ |tag| tag.destroy unless tag_names.include? tag.name }
    tag_names.join ' '
  end

  def self.generate_url
    url = (1..8).collect do
      num = rand(62)
      if num < 26
        (num + 'a'.ord).chr
      elsif num < 52
        (num + 'A'.ord - 26).chr
      else
        (num + '0'.ord - 52).chr
      end
    end
    url.join
  end
end

