require "#{File.dirname(__FILE__)}/spec_helper"

describe 'user' do
  before(:each) do
    @user = User.new(
      :username => 'test user',
      :email => 'test@user.com',
      :firstname => 'Test',
      :lastname => 'User',
      :password => 'testpass',
    )
  end

  specify 'should be valid' do
    @user.should be_valid
  end

  specify 'should require a username' do
    @user = User.new
    @user.should_not be_valid
    @user.errors[:username].should include("Username must not be blank")
    @user.errors[:firstname].should include("Firstname must not be blank")
    @user.errors[:lastname].should include("Lastname must not be blank")
  end
end
