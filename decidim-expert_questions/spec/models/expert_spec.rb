# frozen_string_literal: true

require "rails_helper"

module Decidim::ExpertQuestions
  describe Expert do
    let!(:expert) { create :expert, user: expert_user, component: component, position: position, weight: weight }

    let(:organization) { create :organization, available_locales: [:pl] }
    let(:expert_user) { create :expert_user, :confirmed, organization: organization }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:component) { create :expert_questions_component, participatory_space: participatory_process }

    let(:position) { ::Faker::Lorem.word }
    let(:affiliation) { ::Faker::Lorem.word }
    let(:description) { ::Faker::Lorem.paragraph }
    let(:weight) { 7 }

    context 'when there is position' do
      it 'shows proper position_and_name' do
        position_and_name = "#{position} #{expert_user.name}"
        expect(expert.position_and_name).to eq(position_and_name)
      end
    end

    context 'when there is no position' do
      let(:position) { '' }

      it 'shows proper position_and_name if position is filled' do
        expect(expert.position_and_name).to eq(expert_user.name)
      end
    end

    context "default scope sorts " do
      let(:experts) do
        2.times { |index| create :expert, component: component, weight: index * 8 }
        Decidim::ExpertQuestions::Expert.all
      end

      it 'sorts elements in proper order' do
        expect(experts.map(&:weight)).to eq([0, 7, 8])
        expect(experts.map(&:id)[1]).to eq(expert.id)
      end
    end
  end
end
