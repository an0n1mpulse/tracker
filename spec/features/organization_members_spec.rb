# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Organization Membership Management', js: true do
  context 'As a global super administrator' do
    before :each do
      @existing_user = create :user

      @first_org = create :organization, organization_name: 'First Organization'
      @organization2 = create :organization
    end

    include_context 'login_with_super_admin'

    it 'adds a user to the organization' do
      visit '/'

      click_link 'Organizations'
      click_link @organization2.organization_name

      fill_in 'Email', with: @existing_user.email
      select 'Administrator', from: 'Role'
      click_button 'Add Member'

      expect(page).to have_content @existing_user.name
      expect(@existing_user.reload.has_role?(:admin, @organization2)).to be true
    end
  end
end
