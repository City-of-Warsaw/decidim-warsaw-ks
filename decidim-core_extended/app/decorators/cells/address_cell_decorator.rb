# frozen_string_literal: true

Decidim::AddressCell.class_eval do
  # overwritten method-view
  # use online_new to add location_hints if any
  def show
    return render :online_new if options[:online]

    render
  end

  private

  # overwritten method
  # remove %p
  # stick with simple time format
  def start_time
    l model.start_time, format: "%H:%M"
  end

  # overwritten method
  # remove %p and %Z
  # stick with simple time format
  def end_time
    l model.end_time, format: "%H:%M"
  end

  # overwritten method.
  # uses our map location and applies the road and house number to the meeting address.
  def address
    first_loc = meeting.locations.values.first
    return "" unless first_loc && first_loc["address"].is_a?(Hash)

    address = first_loc["address"]
    [address["road"], address["house_number"]].compact.join(" ")
  end

  # overwritten method
  # add day name
  def start_and_end_time
    day_name = I18n.l(model.start_time, format: "%A")

    <<~HTML
        #{day_name}
        #{with_tooltip(l(model.start_time, format: :tooltip)) { start_time }}
        -
        #{with_tooltip(l(model.end_time, format: :tooltip)) { end_time }}
    HTML
  end
end
