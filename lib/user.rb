require 'dm-core'
require 'dm-types/bcrypt_hash'

class User
  include DataMapper::Resource

  property :id,         Serial
  property :username,   String, :required => true
  property :email,      String, :length => 255
  property :firstname,  String, :required => true
  property :lastname,   String, :required => true
  property :password,   BCryptHash, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime

  validates_presence_of :username
end
