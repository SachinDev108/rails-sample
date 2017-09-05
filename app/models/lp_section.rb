# frozen_string_literal: true

class LpSection < ApplicationRecord # :nodoc:
  include OriginalValidator
  belongs_to :landing_page, inverse_of: 'lp_sections'
  has_many :lp_elements, inverse_of: 'lp_section', dependent: :destroy
  acts_as_paranoid
  mount_uploaders :thumbnails, SectionThumbnailUploader
  validates :name, presence: true
  validates :order, presence: true
end
