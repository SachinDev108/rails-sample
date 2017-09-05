# frozen_string_literal: true

module API
  module V1
    class LpSectionsController < DryController # :nodoc:
      def create
        if params[:meta].present?
          if clonable?
            lps_clone = new_clone(lp_section)
            return unless lps_clone.save
            lps_clone = reorder_section(lps_clone)
            render_response(lps_clone)
          else
            raise BeyondServerException::CloneException, 'Cannot create clone'
          end
        else
          super
        end
      end

      def update
        super
      end

      private

      def reorder_section(lps_clone)
        if clone_data[:order].present?
          lps_clone = order_update(clone_data[:order], lps_clone, landing_page)
        end
        lps_clone
      end

      def clonable?
        lp_section.original? && same_template?
      end

      def same_template?
        lp_section.landing_page.lp_template.eql?(landing_page.lp_template)
      end

      def render_response(lps_clone)
        resource = API::V1::LpSectionResource.new(lps_clone, nil)
        render json: serializer.serialize_to_hash(resource)
      end

      def order_update(order, entity, parent)
        update_order = Reorder.new(order, entity, parent)
        update_order.change_order
      end

      def new_clone(section)
        lps_clone = section.deep_clone include: lps_inclusions,
                                       except: lps_exclusions
        lps_clone.order = new_order
        lps_clone.landing_page_id = landing_page.id
        lps_clone
      end

      def new_order
        landing_page.lp_sections.order(:order).last.order + 1
      end

      def clone_data
        params
          .require(:meta)
          .require(:clone)
          .permit(:type, :id, :order)
      end

      def landing_page_data
        params
          .require(:data)
          .require(:relationships)
          .require(:'landing-page')
          .require(:data)
          .permit(:type, :id)
      end

      def landing_page
        @landing_page ||= LandingPage.find(landing_page_data[:id])
      end

      def lp_section
        LpSection.find_by!(id: clone_data[:id])
      end

      def lps_inclusions
        [:lp_elements]
      end

      def lps_exclusions
        [
          :original, :order,
          {
            lp_elements: [
              :original
            ]
          }
        ]
      end

      def serializer
        JSONAPI::ResourceSerializer.new(API::V1::LpSectionResource)
      end
    end
  end
end
