require "test_helper"

class ContractorsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get contractors_index_url
    assert_response :success
  end

  test "should get show" do
    get contractors_show_url
    assert_response :success
  end

  test "should get new" do
    get contractors_new_url
    assert_response :success
  end

  test "should get edit" do
    get contractors_edit_url
    assert_response :success
  end
end
