# frozen_string_literal: true

Decidim::Meetings::MeetingsController.class_eval do
  helper_method :meetings_help_section

  def index
    return unless search.results.blank? && params.dig("filter", "date") != %w(past)

    @past_meetings = search_klass.new(search_params.merge(date: %w(past)))

    if @past_meetings.results.present?
      params[:filter] ||= {}
      params[:filter][:date] = %w(past)
      @forced_past_meetings = true
      @search = @past_meetings
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  # overwritten - change sor from desc to asc
  def meetings
    @meetings ||= paginate(search.results.order(start_time: :asc))
  end

  def default_filter_params
    {
      search_text: "",
      date: "",
      activity: "all",
      scope_id: default_filter_scope_params,
      category_id: default_filter_category_params,
      origin: default_filter_origin_params,
      type: default_filter_type_params
    }
  end

  def meetings_help_section
    current_component.settings[:help_section]
  end
end


