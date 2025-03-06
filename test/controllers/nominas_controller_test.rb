require "test_helper"

class NominasControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get nominas_index_url
    assert_response :success
  end

  test "should get show" do
    get nominas_show_url
    assert_response :success
  end

  test "should get edit" do
    get nominas_edit_url
    assert_response :success
  end

  test "should get new" do
    get nominas_new_url
    assert_response :success
  end
end
