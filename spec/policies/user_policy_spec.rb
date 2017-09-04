# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy do
  subject { described_class.new current_user, user }
  let(:org) { create :organization }

  context 'as a super administrator' do
    let(:current_user) { create :super_admin }

    context 'on a User resource' do
      let(:user) { User }

      it { is_expected.to permit_action :index }
      it { is_expected.to permit_action :create }
    end

    context 'on another super administrator' do
      let(:user) { create :super_admin }

      it { is_expected.to permit_action :show }
      it { is_expected.to forbid_action :update }
    end

    context 'on a global administrator' do
      let(:user) { create :global_admin }

      it { is_expected.to permit_action :show }
      it { is_expected.to permit_action :update }
    end

    context 'on a teacher' do
      let(:user) { create :teacher_in }

      it { is_expected.to permit_action :show }
      it { is_expected.to permit_action :update }
    end

    context 'on self' do
      let(:user) { current_user }

      it { is_expected.to permit_action :show }
      it { is_expected.to permit_action :update }
    end
  end

  context 'as a global administrator' do
    let(:current_user) { create :global_admin }

    context 'on a User resource' do
      let(:user) { User }

      it { is_expected.to permit_action :index }
      it { is_expected.to permit_action :create }
    end

    context 'on a super administrator' do
      let(:user) { create :super_admin }

      it { is_expected.to permit_action :show }
      it { is_expected.to forbid_action :update }
    end

    context 'on another global administrator' do
      let(:user) { create :global_admin }

      it { is_expected.to permit_action :show }
      it { is_expected.to forbid_action :update }
    end

    context 'on a teacher' do
      let(:user) { create :teacher_in, organization: org }

      it { is_expected.to permit_action :show }
      it { is_expected.to permit_action :update }
    end

    context 'on self' do
      let(:user) { current_user }

      it { is_expected.to permit_action :show }
      it { is_expected.to permit_action :update }
    end
  end

  context 'as a teacher' do
    let(:current_user) { create :teacher_in }

    context 'on a User resource' do
      let(:user) { User }

      it { is_expected.to forbid_action :index }
      it { is_expected.to forbid_action :create }
    end

    context 'on a super administrator' do
      let(:user) { create :super_admin }

      it { is_expected.to forbid_action :show }
      it { is_expected.to forbid_action :update }
    end

    context 'on a global administrator' do
      let(:user) { create :global_admin }

      it { is_expected.to forbid_action :show }
      it { is_expected.to forbid_action :update }
    end

    context 'on another teacher' do
      let(:user) { create :teacher_in }

      it { is_expected.to forbid_action :show }
      it { is_expected.to forbid_action :update }
    end

    context 'on self' do
      let(:user) { current_user }

      it { is_expected.to permit_action :show }
      it { is_expected.to permit_action :update }
    end
  end
end
