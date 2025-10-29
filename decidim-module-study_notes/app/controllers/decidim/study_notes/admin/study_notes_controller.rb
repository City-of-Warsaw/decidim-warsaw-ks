# frozen_string_literal: true

module Decidim::StudyNotes
  class Admin::StudyNotesController < Decidim::StudyNotes::Admin::ApplicationController
    include Decidim::TranslatableAttributes
    include Decidim::SanitizeHelper
    include Decidim::StudyNotes::PdfAnonymisation
    include Decidim::StudyNotes::Admin::Filterable

    helper Decidim::ApplicationHelper
    helper Decidim::StudyNotes::StudyNotesHelper
    helper Decidim::CoreExtended::UrlHelper

    helper_method :study_note

    def index
      enforce_permission_to :manage, :study_notes
      @notes = filtered_collection
    end

    def show
      enforce_permission_to :manage, :study_notes

      pdf_name = study_note.pdf_name

      if params[:anonimized] == "true"
        anonymize_study_note(study_note)
        pdf_name = study_note.anonymized_pdf_name
      end

      respond_to do |format|
        format.html
        format.pdf do
          render pdf: pdf_name,
                 disposition: "attachment",
                 template: study_note.pdf_template,
                 javascript_delay: 2000,
                 locals: { study_note: }
        end
      end
    end

    # Export all or filtered study notes in XLSX format.
    # Uses search filter (params[:q]) if present in the URL.
    # Triggered from the view admin/study_notes/_export_searched_notes.html.erb
    def export
      enforce_permission_to :manage, :study_notes

      @xml_serializer = Decidim::StudyNotes::StudyNotesSerializer.new
      @notes = filtered_collection

      respond_to do |format|
        format.xlsx do
          response.headers["Content-Disposition"] = "attachment; filename=\"Eksport_uwag.xlsx\""
        end
      end
    end

    # Export selected study notes in XLSX format.
    # Receives selected note IDs in params[:ids].
    # Triggered from the view admin/study_notes/_export_chosen_notes.html.erb
    def export_selected
      enforce_permission_to :manage, :study_notes

      @xml_serializer = Decidim::StudyNotes::StudyNotesSerializer.new
      ids = Array(params[:ids]).map(&:to_i)
      @notes = Decidim::StudyNotes::StudyNote.where(id: ids)
      respond_to do |format|
        format.xlsx do
          response.headers["Content-Disposition"] = "attachment; filename=\"Eksport_uwag.xlsx\""
          render "export"
        end
      end
    end

    # Export all or filtered study notes in ZIP format.
    # Uses Decidim::StudyNotes::Admin::StudyNoteZipForm to generate the ZIP.
    # If params[:q] is present, exports filtered notes.
    # NOTE: This action is also (ab)used in the show view of a single study note,
    # passing study_notes: [study_note.id] to generate a ZIP with a single note.
    def export_zip
      enforce_permission_to :manage, :study_notes

      form = form(Decidim::StudyNotes::Admin::StudyNoteZipForm).from_params(params)
      # show view use the same export zip path there is only 1 record
      form.study_notes_ids = filtered_collection.pluck(:id) unless params[:q].nil?

      Decidim::StudyNotes::Admin::LaunchCreatingZipForStudyNotes.call(form, current_component) do
        on(:ok) do
          flash[:notice] = "Przygotowywanie eksportu zostało rozpoczęte. Zostaniesz poinformowany powiadomieniem wysłanym na Twój adres email o zakończeniu procesu"
          redirect_to study_notes_path
        end
      end
    end

    # Export selected study notes in ZIP format.
    # Receives selected note IDs in params[:ids].
    def export_zip_selected
      enforce_permission_to :manage, :study_notes

      form = form(Decidim::StudyNotes::Admin::StudyNoteZipForm).from_params(params)
      form.study_notes_ids = Array(params[:ids]).map(&:to_i)

      Decidim::StudyNotes::Admin::LaunchCreatingZipForStudyNotes.call(form, current_component) do
        on(:ok) do
          flash[:notice] = "Przygotowywanie eksportu zostało rozpoczęte. Zostaniesz poinformowany powiadomieniem wysłanym na Twój adres email o zakończeniu procesu"
          redirect_to study_notes_path
        end
      end
    end

    def get_file
      enforce_permission_to :manage, :study_notes

      study_note_zip = StudyNoteZip.find_by(uuid: params[:uuid])
      return redirect_to study_notes_path if study_note_zip.nil?

      parts = ["Eksport_uwag"]
      parts << "z_zalacznikami" if study_note_zip.with_attachments
      parts << "zanonimizowany" if study_note_zip.anonymized
      parts << "znormalizowany" if study_note_zip.normalized
      selected_file_name = "#{parts.join('_')}.zip"

      send_file ActiveStorage::Blob.service.send(:path_for, study_note_zip.file.blob.key),
                filename: selected_file_name,
                type: study_note_zip.file.blob.content_type,
                disposition: "attachment"
    end

    def map
      enforce_permission_to :manage, :study_notes
      @notes = collection
    end

    # register by admin - only for test purpose
    def register_to_signum
      enforce_permission_to :manage, :study_notes

      Decidim::StudyNotes::Admin::RegisterToSignum.call(current_component, current_user, study_note) do
        on(:registered_already) do
          flash[:alert] = "Ten projekt już jest zarejestrowany w Signum."
        end

        on(:invalid_login) do
          flash[:alert] = "Projekt nie został zarejestrowany z powodu braku konta '#{current_user.ad_name}' w Signum"
        end

        on(:ok) do
          flash[:notice] = "Zarejestrowano projekt w Signum"
        end
      end
      redirect_to study_note_path(study_note)
    end

    def sequential_numbers
      enforce_permission_to :manage, :study_notes

      @form = Decidim::StudyNotes::Admin::SequentialNumberForm.new
    end

    def generate_sequential_numbers
      enforce_permission_to :manage, :study_notes

      @form = Decidim::StudyNotes::Admin::SequentialNumberForm.from_params(params)
      Decidim::StudyNotes::Admin::GenerateSequentialNumbers.call(@form, current_component) do
        on(:invalid) do
          flash[:alert] = "Wystąpił błąd"
          render :sequential_numbers
        end

        on(:ok) do
          flash[:notice] = "Generowanie numerów zostało rozpoczęte. Zostaniesz poinformowany powiadomieniem wysłanym na Twój adres email o zakończeniu procesu"
          redirect_to study_notes_path
        end
      end
    end

    private

    def collection
      @collection ||= Decidim::StudyNotes::StudyNote.where(component: current_component)
    end

    def study_note
      @study_note ||= collection.find params[:id]
    end
  end
end
