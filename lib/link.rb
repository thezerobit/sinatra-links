require 'dm-core'

class Link
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String, :required => true, :unique_index => true
  property :address,    String, :required => true, :unique_index => true, :length => 255
  property :votes,      Integer, :required => true, :default => 0
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :user
  has n, :linkvote
  has n, :linktag

  def save_tags tagtext
    tag_names = tagtext.split(/[, ]+/).map{ |t| t.downcase }
    tag_names.each do |tagtext|
      Linktag.first_or_create(
        {:name => tagtext, :link => self},
        {:name => tagtext, :link => self},
      )
    end
    linktag.each{ |tag| tag.destroy unless tag_names.include? tag.name }
    tag_names.join ' '
  end
end

