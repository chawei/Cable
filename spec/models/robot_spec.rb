describe "Robot" do
  
  it "should say hello" do
    robot = Robot.instance
    
    request = 'hello'
    robot.listen request
    
    robot.response[:message].should == 'hi there'
  end
end