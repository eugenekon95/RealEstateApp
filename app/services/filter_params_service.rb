# frozen_string_literal: true

class FilterParamsService

  ORDER_TYPES = {
    'Recently updated' => { updated_at: { order: :desc, unmapped_type: 'long' } },
    'Low Price First' => { price: { order: :asc, unmapped_type: 'long' } },
    'High Price First' => { price: { order: :desc, unmapped_type: 'long' } },
    'Newest' => { created_at: { order: :desc, unmapped_type: 'long' } },
    'Alphabetical' => { property_type: { order: :asc, unmapped_type: 'long' } }
  }.freeze

  def initialize(params = {})
    @params = params
  end

  def call
    {
      min_bedrooms: @params[:min_bedrooms],
      min_price: @params[:min_price],
      max_price: @params[:max_price],
      brokerage_id: @params[:brokerage_id],
      closest_open_house: @params[:closest_open_house],
      query: @params[:query],
      city: @params[:city],
      order: order_type(@params[:order]),
      page: @params[:page]
    }.reject { |_, value| value.blank? }
  end

  private

  def order_type(type)
    ORDER_TYPES[type] || ORDER_TYPES['Newest']
  end
end
