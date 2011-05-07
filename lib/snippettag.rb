require 'dm-core'

class Snippettag
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :snippet
end


