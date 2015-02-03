require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase


  test "should sign up new user" do
    request.env["devise.mapping"] = Devise.mappings[:user]

    assert_difference('User.count') do
      post :create, user: { first_name: 'First Name', last_name: 'Last Name', year_of_birth: '1980', email: 'new_user@example.com', password: 'password' }
    end

    assert_not_nil assigns(:user)
    assert_equal 'First Name', assigns(:user).first_name
    assert_equal 'Last Name', assigns(:user).last_name
    assert_equal 1980, assigns(:user).year_of_birth
    assert_equal 'new_user@example.com', assigns(:user).email

    assert_redirected_to get_started_path
  end

  test "should not sign up new user without required fields" do
    request.env["devise.mapping"] = Devise.mappings[:user]

    assert_difference('User.count', 0) do
      post :create, user: { first_name: '', last_name: '', year_of_birth: '', email: '', password: '' }
    end

    assert_not_nil assigns(:user)

    assert assigns(:user).errors.size > 0
    assert_equal ["can't be blank"], assigns(:user).errors[:first_name]
    assert_equal ["can't be blank"], assigns(:user).errors[:last_name]
    assert_equal ["can't be blank", "is not a number"], assigns(:user).errors[:year_of_birth]
    assert_equal ["can't be blank"], assigns(:user).errors[:email]
    assert_equal ["can't be blank"], assigns(:user).errors[:password]

    assert_template 'devise/registrations/new'
    assert_response :success
  end

  test "should not sign up new user without meeting minimum age requirements" do
    request.env["devise.mapping"] = Devise.mappings[:user]

    assert_difference('User.count', 0) do
      post :create, user: { first_name: 'First Name', last_name: 'Last Name', year_of_birth: "#{Date.today.year - 17}", email: 'new_user@example.com', password: 'password' }
    end

    assert_not_nil assigns(:user)

    assert assigns(:user).errors.size > 0
    assert_equal ["must be less than or equal to #{Date.today.year - 18}"], assigns(:user).errors[:year_of_birth]

    assert_template 'devise/registrations/new'
    assert_response :success
  end

  test "should not sign up new user born before 1900" do
    request.env["devise.mapping"] = Devise.mappings[:user]

    assert_difference('User.count', 0) do
      post :create, user: { first_name: 'First Name', last_name: 'Last Name', year_of_birth: "1899", email: 'new_user@example.com', password: 'password' }
    end

    assert_not_nil assigns(:user)

    assert assigns(:user).errors.size > 0
    assert_equal ["must be greater than or equal to 1900"], assigns(:user).errors[:year_of_birth]

    assert_template 'devise/registrations/new'
    assert_response :success
  end

  test "should sign up user with a specified provider" do
    request.env["devise.mapping"] = Devise.mappings[:user]

    assert_difference('User.count') do
      post :create, user: { first_name: 'First Name', last_name: 'Last Name', year_of_birth: '1980', email: 'new_user@example.com', password: 'password', provider_id: users(:provider_1).id }
    end

    assert_not_nil assigns(:user)
    assert_equal users(:provider_1), assigns(:user).provider
    assert_redirected_to get_started_path
  end

  test "should sign up provider" do
    request.env["devise.mapping"] = Devise.mappings[:user]

    assert_difference('User.providers.count') do
      post :create, user: { first_name: 'First Name', last_name: 'Last Name', email: 'new_provider@example.com', password: 'password', user_type: 'provider' }
    end

    assert_not_nil assigns(:user)
    assert_equal 'First Name', assigns(:user).first_name
    assert_equal 'Last Name', assigns(:user).last_name
    assert_equal 'new_provider@example.com', assigns(:user).email
    assert_equal 'provider', assigns(:user).user_type

    assert_redirected_to get_started_path
  end

  test "should not sign up provider without required fields" do
    request.env["devise.mapping"] = Devise.mappings[:user]

    assert_difference('User.count', 0) do
      post :create, user: { first_name: '', last_name: '', email: 'new_provider@example.com', password: 'password', user_type: 'provider' }
    end

    assert_not_nil assigns(:user)
    assert assigns(:user).errors.size > 0
    assert_equal ["can't be blank"], assigns(:user).errors[:first_name]
    assert_equal ["can't be blank"], assigns(:user).errors[:last_name]

    assert_template partial: 'providers/_signup_form'
    assert_response :success
  end

end
