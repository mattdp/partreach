require 'test_helper'

class DialoguesControllerTest < ActionController::TestCase
  setup do
    @dialogue = dialogues(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dialogues)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dialogue" do
    assert_difference('Dialogue.count') do
      post :create, dialogue: { initial_select: @dialogue.initial_select, opener_sent: @dialogue.opener_sent, response_received: @dialogue.response_received }
    end

    assert_redirected_to dialogue_path(assigns(:dialogue))
  end

  test "should show dialogue" do
    get :show, id: @dialogue
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @dialogue
    assert_response :success
  end

  test "should update dialogue" do
    put :update, id: @dialogue, dialogue: { initial_select: @dialogue.initial_select, opener_sent: @dialogue.opener_sent, response_received: @dialogue.response_received }
    assert_redirected_to dialogue_path(assigns(:dialogue))
  end

  test "should destroy dialogue" do
    assert_difference('Dialogue.count', -1) do
      delete :destroy, id: @dialogue
    end

    assert_redirected_to dialogues_path
  end
end
