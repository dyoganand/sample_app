require 'spec_helper'

describe "MicropostPages" do
  
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "micropost creation" do
  	before { visit root_path }

  	describe "with valid information" do
  		
  		it "should not create" do
  			expect { click_button "Post" }.not_to change(Micropost, :count)
  		end
  	end

  	describe "with valid information" do
  		before { fill_in 'micropost_content', with: "Lorem ipsum" }
  		it "should create a micropost" do
  			expect { click_button "Post" }.to change(Micropost, :count).by(1)
  		end
  	end
  end
end
