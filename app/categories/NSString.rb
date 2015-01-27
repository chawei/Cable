class NSString
  def urlEncodeUsingEncoding(encoding)
  	return CFURLCreateStringByAddingPercentEscapes(nil, self, nil, 
              "!*'\"();:@&=+$,/?%#[]% ", 
              CFStringConvertNSStringEncodingToEncoding(encoding))
  end
end