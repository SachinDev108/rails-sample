# frozen_string_literal: true

module API
  module V1
    class LpSectionResource < JSONAPI::Resource # :nodoc:
      attributes :name, :order, :identifier, :original, :thumbnails
      has_one :landing_page

      def fetchable_fields
        super - [:original]
      end
    end
  end
end
