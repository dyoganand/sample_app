require 'spec_helper'

describe "Authentication" do

	subject { page }
	
	describe "sign in page" do
		before { visit signin_path }

		it { should have_title('Sign In') }
		it { should have_content('Sign In') }
	end

	describe "signin" do
		before { visit signin_path }

		describe "with invalid information" do
			before { click_button "Sign In" }

			it { should have_title('Sign In') }
			it { should have_selector('div.alert.alert-error') }

			describe "after visiting another page" do
				before { click_link "Home" }
				it { should_not have_selector('div.alert.alert-error') }
			end
		end

		describe "with valid information" do
			let(:user) { FactoryGirl.create(:user) }
			before { sign_in user }
			
			it { should have_title(user.name) }
			it { should have_link("Users", href: users_path) }
			it { should have_link("Profile", href: user_path(user)) }
			it { should have_link("Settings", href: edit_user_path(user)) }
			it { should have_link("Sign out", href: signout_path) }
			it { should_not have_link("Sign in", href: signin_path) }

			describe "followed by sign out" do
				before { click_link "Sign out" }
				it { should have_link("Sign in", href:signin_path) }
			end
		end
	end

	describe "authorization" do
		describe "for non-signed in users" do
			let(:user) { FactoryGirl.create(:user) }
			
			describe "when attempting to visit a protected page" do
				before do
				  visit edit_user_path(user)
				  fill_in "Email", with: user.email
				  fill_in "Password", with: user.password
				  click_button "Sign In"
				end
				describe "after signing in" do
					it "should render the desired protected page" do
						expect(page).to have_title('Edit user')
					end
				end
			end

			describe "in the users controller" do
				describe "visiting the edit page" do
					before { visit edit_user_path(user) }
					it { should have_title('Sign In') }
				end

				describe "submitting to update action" do
					# Send the user info as hash to the update action
					before { patch user_path(user), :user => FactoryGirl.attributes_for(:user) }
					specify { expect(response).to redirect_to(signin_path) }
				end

				describe "visiting the user index" do
					before { visit users_path }
					it { should have_title('Sign In') }
				end
			end
		end

		describe "as wrong user" do
			let(:user) { FactoryGirl.create(:user) }
			let(:wrong_email) { "wrong@example.com" }
			let(:wrong_user) { FactoryGirl.create(:user, email: wrong_email) }
			before { sign_in user, no_capybara: true }
			
			# Trying to edit and update the wrong user information
			describe "submitting a GET request to Users#edit action" do
				before { get edit_user_path(wrong_user) }
				specify { expect(response.body).not_to match(full_title('Edit user')) }	
				specify { expect(response).to redirect_to(root_url) }	
			end

			describe "submitting a PATCH request to Users#update action" do
				before { patch user_path(wrong_user), :user => FactoryGirl.attributes_for(:user, email: wrong_email) }
				# before { patch user_path(wrong_user) }
				specify { expect(response).to redirect_to(root_url) }
			end
		end

		describe "as non-admin user" do
			let(:user) { FactoryGirl.create(:user) }
			let(:non_admin) { FactoryGirl.create(:user) }
			let(:admin) { FactoryGirl.create(:admin) }
			
			describe "submitting a delete request to Users#destroy action" do
				before do
					sign_in non_admin, no_capybara: true
					delete user_path(user)
				end 
				specify { expect(response).to redirect_to(root_url) }
			end
		end

		describe "admin submiting a delete request to self" do
			let(:user) { FactoryGirl.create(:user) }
			let(:non_admin) { FactoryGirl.create(:user) }
			let(:admin) { FactoryGirl.create(:admin) }
			before do
			  sign_in admin, no_capybara: true
			  delete user_path(admin)
			end
			specify { expect(response).to redirect_to(root_url) }
		end
	end

end