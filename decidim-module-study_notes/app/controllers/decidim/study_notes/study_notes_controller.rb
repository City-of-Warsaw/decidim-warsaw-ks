# frozen_string_literal: true

require_dependency "decidim/study_notes/application_controller"

module Decidim::StudyNotes
  class StudyNotesController < ApplicationController
    include Decidim::FormFactory

    helper_method :study_note, :backgrounds, :legends

    def index
      @form = form(Decidim::StudyNotes::StudyNoteForm).instance
    end

    def create
      @form = form(Decidim::StudyNotes::StudyNoteForm).from_params(params)
      if params[:subaction] == "preview_pdf"
        # Handle PDF preview without saving the record
        render pdf: "podgląd wniosku",
               template: "decidim/study_notes/shared/show",
               disposition: "inline",
               formats: [:pdf],
               locals: { study_note: @form }
      else
        Decidim::StudyNotes::CreateStudyNote.call(@form) do
          on(:ok) do |study_note|
            redirect_to study_note_path(study_note, uuid: study_note.uuid, anchor: "subcontent")
          end

          on(:invalid) do
            flash.now[:alert] = t("study_notes.create.invalid", scope: "decidim.study_notes")
            render :index
          end
        end
      end
    end

    def show
      unless study_notes_token_verified?
        flash.now[:alert] = "Niepoprawny link"
        redirect_to(study_notes_path) && (return)
      end

      respond_to do |format|
        format.html
        format.pdf do
          render pdf: study_note.pdf_name, disposition: "attachment", template: study_note.pdf_template
        end
      end
    end

    private

    def study_notes_token_verified?
      study_note.uuid == params[:uuid]
    end

    def study_note
      @study_note ||= StudyNote.where(component: current_component).find_by(uuid: params[:uuid])
    end

    def legends
      @legends ||= Decidim::StudyNotes::LegendItem.where(component: current_component).sorted.group_by(&:map_background_id)
    end

    def backgrounds
      @backgrounds ||= Decidim::StudyNotes::MapBackground.where(component: current_component).sorted
    end
  end
end
