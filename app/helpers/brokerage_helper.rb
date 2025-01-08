# frozen_string_literal: true

module BrokerageHelper
  def brokerages_for_select
    Brokerage.all.map { |brokerage| [brokerage.name, brokerage.id] }
  end
end
