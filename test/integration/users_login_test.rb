# coding: utf-8
require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "login with invalid information" do
    get login_path # ログイン用のパスを開く
    assert_template "sessions/new" # 新しいセッションのフォームが正しく表示されたことを確認する
    post login_path, params: {session: {email: "", password: ""}} # わざと無効なparamsハッシュを使ってセッション用のパスにPOST
    assert_template 'sessions/new'
    assert_not flash.empty? # 新しいセッションのフォームが再度表示されflashメッセージが追加されることを確認
    get root_path # Homeページに移動
    assert flash.empty? # Homeページでflashメッセージが表示されないことを確認
  end

  test "login with valid information followed by logout" do
    get login_path
    post login_path, params: {session: {email: @user.email,
                                        password: 'password'}}
    assert is_logged_in?
    assert_redirected_to @user #リダイレクト先が正しいことを確かめる
    follow_redirect! # 実際に移動
    assert_template 'users/show' 
    assert_select "a[href=?]", login_path, count: 0 # loginへのパスが存在しない
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count:0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
end
