class CodeBook < ActiveModelSerializers::Model
  def codes
    PhotoCode.all
  end

  def groups
    PhotoCodeGroup.all
  end
end
