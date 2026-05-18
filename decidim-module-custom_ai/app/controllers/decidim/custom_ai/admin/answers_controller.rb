# frozen_string_literal: true

module Decidim
  module CustomAi
    module Admin
      class AnswersController < Decidim::CustomAi::Admin::ApplicationController
        include Decidim::CustomAi::Admin::Filterable

        helper Decidim::ApplicationHelper
        helper_method :current_component, :current_participatory_space, :answer, :tags


        def index
          @answers = filtered_collection
          @grouping = if params.present? && params.key?(:q) && params[:q].key?(:other_grouping_eq)
                        params[:q][:other_grouping_eq].to_i
                      end
          if @grouping.present?
            @answers = @answers.where.not(similar_group_id: nil)
          end
        end

        def show; end

        def edit
          @form = form(Decidim::CustomAi::Admin::AnswerForm).from_model(answer)
        end

        # Updates a single Decidim::Forms::Answer with submitted attributes.
        # Broadcasts :ok or :invalid.
        # Triggered from standard edit form.
        def update
          @form = form(Decidim::CustomAi::Admin::AnswerForm).from_params(params)

          Decidim::CustomAi::Admin::UpdateAnswer.call(answer, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("answer.update.success", scope: "decidim.admin")

              redirect_to decidim_custom_ai_admin.answer_path(id: answer.id)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("answer.update.errors", scope: "decidim.admin")
              render :edit
            end
          end
        end

        # Public: Schedule export of all answers for the current component.
        #
        # This action takes the answers from the current collection and enqueues a job
        # to generate an XLSX export. Each answer is serialized and attached to a file.
        #
        # Broadcasts events:
        #   :ok      - when the export job was successfully scheduled
        #   :invalid - when the export could not be scheduled
        #
        # Triggered from the view: decidim/custom_ai/admin/answers/index.html.erb
        #
        # Redirects to the answers index path with a flash message.
        def export
          @answers = collection

          Decidim::CustomAi::Admin::ScheduleAnswersExport.call(current_component, current_user, @answers) do
            on(:ok) { flash[:notice] = I18n.t("answer.export.success", scope: "decidim.admin") }
            on(:invalid) { flash[:alert] = I18n.t("answer.export.error", scope: "decidim.admin") }

            redirect_to decidim_custom_ai_admin.answers_path
          end
        end

        # Public: Mark selected answers as accepted.
        #
        # This action receives an array of answer IDs via `params[:ids]`. If no IDs
        # are provided, it will mark all answers in the current collection as accepted.
        #
        # Updates the `status` attribute to `:accepted` and creates a new version
        # for each updated answer.
        #
        # Broadcasts events:
        #   :ok      - when the operation was successful
        #   :invalid - when no answer IDs at all were provided
        #
        # Triggered from the view: decidim/custom_ai/admin/answers/index.html.erb
        #
        # Returns JSON: "ok" on success
        def mark_as_accepted
          Decidim::CustomAi::Admin::MarkAnswersAsAccepted.call(current_user, answer_ids) do
            on(:ok) { flash[:notice] = I18n.t("answer.mark_as_accepted.success", scope: "decidim.admin") }
            on(:invalid) { flash[:alert] = I18n.t("answer.mark_as_accepted.error", scope: "decidim.admin") }

            render json: "ok"
          end
        end

        # Public: Initialize the AI decision batch form for a set of answers.
        #
        # This action receives an array of answer IDs via `params[:ids]`. If none are provided,
        # it will initialize the form for all answers in the current collection.
        #
        # redirect to the form
        def init_ai_decision_form
          @form = form(Decidim::CustomAi::Admin::BatchAiDecisionForm).instance
          @form.answer_ids = answer_ids
        end

        # Public: Update AI decision attributes for selected answers.
        #
        # This action receives an array of answer IDs via `params[:ids]`. If no IDs
        # are provided, it will update all answers in the current collection.
        #
        # It updates only the AI-related attributes (`ai_decision_body` and
        # `ai_decision_status`) and creates a new version for each updated answer.
        #
        # Broadcasts events:
        #   :ok      - when the operation was successful
        #   :invalid - when no answer IDs were provided
        #
        # Triggered from the view: decidim/custom_ai/admin/answers/index.html.erb
        #
        # Redirects to the answers index path with a flash message.
        def update_ai_decision
          @form = form(Decidim::CustomAi::Admin::BatchAiDecisionForm).from_params(params)

          Decidim::CustomAi::Admin::UpdateAnswersAiDecision.call(current_user, @form) do
            on(:ok) { flash[:notice] = I18n.t("answer.update_ai_decision.success", scope: "decidim.admin") }
            on(:invalid) { flash[:alert] = I18n.t("answer.update_ai_decision.error", scope: "decidim.admin") }

            redirect_to decidim_custom_ai_admin.answers_path
          end
          end

        def update_grouping
          Decidim::CustomAi::Admin::UpdateAiGrouping.call(current_user, current_component) do
            on(:ok) { flash[:notice] = I18n.t("answer.update_ai_grouping.success", scope: "decidim.admin") }
            on(:invalid) { flash[:alert] = I18n.t("answer.update_ai_grouping.error", scope: "decidim.admin") }

            redirect_to decidim_custom_ai_admin.answers_path
          end
        end

        def init_import_ai_decisions_form
          @form = form(Decidim::CustomAi::Admin::ImportAiDecisionsForm).instance
        end

        def import_ai_decisions
          @form = form(Decidim::CustomAi::Admin::ImportAiDecisionsForm).from_params(params)

          Decidim::CustomAi::Admin::ImportAiDecisions.call(current_user, @form, collection) do
            on(:ok) { flash[:notice] = I18n.t("answer.import_ai_decision.success", scope: "decidim.admin") }
            on(:invalid) { flash[:alert] = I18n.t("answer.import_ai_decision.error", scope: "decidim.admin") }

            redirect_to decidim_custom_ai_admin.answers_path
          end
        end

        def regenerate_pending_answers_from_ai
          answers_list = collection.where(status: :pending)
          Decidim::CustomAi::RegenerateAnswerDecisionJob.perform_later(answers_list.pluck(:id), current_component, current_user)

          flash[:notice] = I18n.t("answer.regenerate_ai_decision.success", scope: "decidim.admin")
          redirect_to decidim_custom_ai_admin.answers_path
        end


        private


        def collection
          @collection ||= Decidim::Forms::Answer.joins(:question, :questionnaire)
                                                .where(questionnaire: questionnaires, question: long_answer_questions)
                                                .order(created_at: :desc)
        end

        def answer_ids
          @answer_ids ||= if params[:ids].present?
                            Array(params[:ids]).map(&:to_i)
                          else
                            collection.pluck(:id)
                          end
        end

        def answer
          @answer ||= collection.find(params[:id])
        end

        def surveys
          @surveys ||= Decidim::Surveys::Survey.joins(:component, :questionnaire)
                                               .where(component: current_component)
        end

        def questionnaires
          @questionnaires ||= Decidim::Forms::Questionnaire.includes(:questionnaire_for)
                                                           .where(
                                                             questionnaire_for_type: Decidim::Surveys::Survey.name,
                                                             questionnaire_for_id: surveys.select(:id)
                                                           )
        end

        def long_answer_questions
          @long_answer_questions ||= Decidim::Forms::Question.joins(:questionnaire)
                                                             .where(
                                                               questionnaire: questionnaires,
                                                               question_type: "long_answer"
                                                             )
        end

      end
    end
  end
end
