# frozen_string_literal: true

class Reorder # :nodoc:
  def initialize(order, entity, parent)
    @entity = entity
    @order = order
    @parent = parent
  end

  def change_order
    parent_id = (@parent.class.name.underscore.to_s + '_id').to_sym
    entities = @entity.class.where(parent_id => @parent.id)
    curr_order = entities.order(:order).pluck(:id)
    return unless validate_order(entities)
    new_order = sort_order(curr_order)
    update_order(entities, new_order)
  end

  def check_order(entity, index)
    entity.order.equal?(index + 1)
  end

  def sort_order(curr_order)
    old_val = curr_order.index(@entity.id)
    curr_order.insert(@order - 1, curr_order.delete_at(old_val))
  end

  def update_order(entities, new_order)
    new_order.each_with_index do |id, index|
      entity = entities.find(id)
      entity.update_column(:order, index + 1) unless check_order(entity, index)
    end
    @entity.reload
  end

  def validate_order(entities)
    @order.to_i.positive? && @order.to_i <= entities.length
  end
end
