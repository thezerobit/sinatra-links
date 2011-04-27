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
end

