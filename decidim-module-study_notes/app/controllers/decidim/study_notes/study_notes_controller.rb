# frozen_string_literal: true
require_dependency "decidim/study_notes/application_controller"

module Decidim::StudyNotes
  class StudyNotesController < ApplicationController
    include Decidim::FormFactory

    helper_method :study_note, :backgrounds, :legends

    def index
      @form = form(Decidim::StudyNotes::StudyNoteForm).from_model(Decidim::StudyNotes::StudyNote.new(locations: params[:coords]))
    end

    def create
      @form = form(Decidim::StudyNotes::StudyNoteForm).from_params(params)
      Decidim::StudyNotes::CreateStudyNote.call(@form) do
        on(:ok) do |study_note|
          redirect_to study_note_path(study_note) + "#subcontent"
        end

        on(:invalid) do
          flash.now[:alert] = t("study_notes.create.invalid", scope: "decidim.study_notes")
          render :index
        end
      end
    end

    def show
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "#{study_note.id}_potwierdzenie", disposition: 'attachment', template: study_note.pdf_template
        end
      end
    end

    private

    def study_note
      @study_note ||= StudyNote.find params[:id]
    end

    def legends
      @legends ||= Decidim::StudyNotes::LegendItem.where(component: current_component).sorted.group_by(&:map_background_id)
    end

    def backgrounds
      @backgrounds ||= Decidim::StudyNotes::MapBackground.where(component: current_component).sorted
    end
  end
end
