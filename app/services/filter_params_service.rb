# frozen_string_literal: true

class FilterParamsService
  ORDER_TYPES = {
    'Recently updated' => { updated_at: :desc },
    'Low Price First' => { price: :asc },
    'High Price First' => { price: :desc },
    'Newest' => { created_at: :desc },
    'Alphabetical' => { property_type: :asc }
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
