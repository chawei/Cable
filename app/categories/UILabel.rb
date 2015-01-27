class UILabel
  
  def setVerticalAlignmentTop
    setVerticalAlignmentTopWithHeight(200)
  end
  
  def setVerticalAlignmentTopWithHeight(height)
    if self.text
      textSize = self.text.sizeWithFont self.font,
                                constrainedToSize:[self.frame.size.width, height],
                                    lineBreakMode:NSLineBreakByWordWrapping

      textRect = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            textSize.height)
      self.setFrame textRect
      self.setNeedsDisplay
    end
  end
end