# frozen_string_literal: true

Decidim::Followable.class_eval do
  # overwritten method
  # break decidim philosophy - each space has its own followers - not involve the process
  # remove participatory_space
  def followers
    super
  end
end
