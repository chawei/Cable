class SongObject
  
  attr_accessor :title
  attr_accessor :subtitle
  attr_accessor :source
  
  def initialize(params)
    self.title    = params[:title]
    self.subtitle = params[:subtitle]
    self.source   = params[:source]
  end
end