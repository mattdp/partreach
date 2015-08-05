require 'spec_helper'

feature "Enterprise landing page" do
  scenario "should load" do
    visit enterprise_path

    page.should have_content "He pays attention to detail"
  end
end