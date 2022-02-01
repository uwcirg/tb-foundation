class CodeBook < ActiveModelSerializers::Model

  def codes
    PhotoCode.all
  end

  def groups
    PhotoCodeGroup.all
  end

  def colors
    PhotoReviewColor.all
  end

  def versions
    TestStripVersion.all
  end

end
