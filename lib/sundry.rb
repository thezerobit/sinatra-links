class DataMapper::Property
  def human_name
    @name.to_s.split("_").map{ |x| x.capitalize }.join ' '
  end
  def input_type
    case @class
      when DataMapper::Property::BCryptHash then 'password'
      else 'text'
    end
  end
  def form_field?
    allowed = [
      DataMapper::Property::String,
      DataMapper::Property::Text,
      DataMapper::Property::BCryptHash,
    ]
    allowed.include? @class
  end
  def get_class
    @class.to_s
  end
end
