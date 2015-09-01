require "spec_helper"

feature "Provider-based requests" do

  before(:each) do
    @team_user = FactoryGirl.create :team_user
    sign_in @team_user
  end

  scenario "Provider index page" do
    visit teams_index_path
    page.should have_content "are using to make parts"
  end

  scenario "All providers page" do
    visit organizations_providers_list_path(@team_user.team.organization.id)
    page.should have_content "Company Name"
  end

  scenario "All tags page" do
    visit organizations_tags_list_path(@team_user.team.organization.id)
    page.should have_content "# suppliers"
  end

end
