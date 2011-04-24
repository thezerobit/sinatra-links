require 'dm-core'
require 'dm-types/bcrypt_hash'

class User
  include DataMapper::Resource

  property :id,         Serial
  property :username,   String, :required => true, :unique_index => true
  property :email,      String, :length => 255
  property :first_name,  String, :required => true
  property :last_name,   String, :required => true
  property :password,   BCryptHash, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime

  def self.form_fields
    [
      { :name => 'username', :title => 'Username', },
      { :name => 'firstname', :title => 'First Name', },
      { :name => 'lastname', :title => 'Last Name', },
      { :name => 'email', :title => 'Email Address', },
      { :name => 'password', :title => 'Password', :type => 'password', },
    ]
  end

end
