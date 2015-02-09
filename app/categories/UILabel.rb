class UILabel
  
  def setVerticalAlignmentTop
    setVerticalAlignmentTopWithHeight(200)
  end
  
  def setVerticalAlignmentTopWithHeight(height)
    if self.text
      constraintSize = [self.frame.size.width, height]
      
      # These two ways are wrong!!
      #textSize = self.text.boundingRectWithSize(constraintSize,
      #                        options:NSStringDrawingUsesLineFragmentOrigin,
      #                        attributes: { NSFontAttributeName => self.font },
      #                        context:nil).size
      
      #textSize = self.text.sizeWithFont self.font,
      #                          constrainedToSize:[self.frame.size.width, height],
      #                              lineBreakMode:self.lineBreakMode
      
      textSize = self.sizeThatFits constraintSize
      textRect = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            textSize.height)
      self.setFrame textRect
      self.setNeedsDisplay
    end
  end
  
  def setVerticalAlignmentTopWithConstraintSize(constraintSize)
    if self.text      
      textSize = self.sizeThatFits constraintSize
      textRect = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            textSize.width,
                            textSize.height)
      self.setFrame textRect
      self.setNeedsDisplay
    end
  end
end