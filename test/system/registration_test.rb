# frozen_string_literal: true

require "application_system_test_case"

class RegistrationTest < ApplicationSystemTestCase
  test "register user" do
    fake_origin = ENV['WEBAUTHN_ORIGIN']
    fake_client = WebAuthn::FakeClient.new(fake_origin)
    fixed_challenge = SecureRandom.random_bytes(32)

    visit new_registration_path

    fake_credentials = fake_client.create(challenge: fixed_challenge)
    stub_create(fake_credentials)

    fill_in "registration_username", with: "User1"
    fill_in "Credential Nickname", with: "USB key"

    WebAuthn::CredentialCreationOptions.stub_any_instance :challenge, fixed_challenge do
      click_on "Register using WebAuthn"
      # wait for async response
      assert_button "account_circle"
    end

    assert_current_path "/"
    assert_text 'USB key'
  end
end