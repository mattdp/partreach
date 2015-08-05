require 'spec_helper'

feature "Enterprise landing page" do
  scenario "should load" do
    visit enterprise_path

    page.should have_content "He pays attention to detail"
  end

  scenario "should collect emails" do
    visit enterprise_path

    expect(Lead.all.size).to eq 0

    page.fill_in "upper", with: "fakeemail@fake.com"
    page.click_button "upper-submit"

    expect(Lead.all.size).to eq 1
  end
end