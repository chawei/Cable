describe HomeViewController do
  tests HomeViewController, :storyboard => 'main', :id => 'HomeViewController'
  
  describe 'profile_button' do
    it "is connected in the storyboard" do
      controller.profile_button.should.not.be.nil
    end
  end
end