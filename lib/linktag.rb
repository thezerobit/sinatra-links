require 'dm-core'

class Linktag
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :link
end


