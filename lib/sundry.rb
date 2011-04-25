require 'dm-core'
require 'dm-types'
require 'dm-types/bcrypt_hash'

class DataMapper::Property
  def human_name
    @name.to_s.split("_").map{ |x| x.capitalize }.join ' '
  end
  def input_type
    'text'
  end
  def form_field?
    false
  end
end

string_classes = [
  DataMapper::Property::String,
  DataMapper::Property::Text,
]
password_classes = [
  DataMapper::Property::BCryptHash,
]
string_classes.each do |k|
  k.class_eval do 
    def form_field?
      true
    end
  end
end
password_classes.each do |k|
  k.class_eval do 
    def input_type
      'password'
    end
    def form_field?
      true
    end
  end
end

