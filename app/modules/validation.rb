module Validation
  
  def validate_objects(objects)
    validate_objects = []
    objects.each do |object|
      if object.class == Hash
        validate_objects << object
      end
    end
    validate_objects
  end
  
end