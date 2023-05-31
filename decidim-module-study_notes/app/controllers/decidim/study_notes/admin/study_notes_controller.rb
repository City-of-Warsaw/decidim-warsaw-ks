# frozen_string_literal: true

module Decidim::StudyNotes
  class Admin::StudyNotesController < Decidim::StudyNotes::Admin::ApplicationController
    helper Decidim::ApplicationHelper
    helper_method :study_note

    def index
      # enforce_permission_to :manage, :study_note
      @notes = collection.page(params[:page]).per(15)
    end

    def show
      # enforce_permission_to :manage, :study_note
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "#{study_note.id}_potwierdzenie", disposition: 'attachment', template: study_note.pdf_template
        end
      end
    end

    def export
      @notes = collection
      respond_to do |format|
        format.xlsx
        format.text { send_data render_to_string(:export), filename: "eksport_geojson-#{Time.now.strftime("%d.%m.%Y_%H-%M")}.geojson", type: 'text/plain', disposition: 'attachment' }
      end
    end

    private

    def collection
      @collection ||= Decidim::StudyNotes::StudyNote.where(component: current_component).order(created_at: :desc)
    end

    def study_note
      @study_note ||= collection.find params[:id]
    end
  end
end
