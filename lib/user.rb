require 'dm-core'
require 'dm-types/bcrypt_hash'

class User
  include DataMapper::Resource

  property :id,         Serial
  property :username,   String, :required => true, :unique_index => true
  property :email,      String, :length => 255
  property :first_name, String, :required => true
  property :last_name,  String, :required => true
  property :password,   BCryptHash, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :link
  has n, :linkvote
end
