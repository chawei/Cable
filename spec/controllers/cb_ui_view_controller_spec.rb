describe "CBUIViewController" do
  tests CBUIViewController
  
  it "should prefer UIInterfaceOrientationPortrait" do
    controller.preferredInterfaceOrientationForPresentation.should == UIInterfaceOrientationPortrait
  end
end