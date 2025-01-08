# frozen_string_literal: true

module Admin
  class BrokeragesController < Admin::BaseController
    def index
      @brokerages = Brokerage.all
    end

    def create
      @brokerage = Brokerage.new(brokerage_params)

      respond_to do |format|
        if @brokerage.save
          format.html { redirect_to admin_brokerages_url(@brokerage), notice: 'Brokerage was successfully created.' }
          format.json { render :show, status: :created, location: @brokerage }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @brokerage.errors, status: :unprocessable_entity }
        end
      end
    end

    def new
      @brokerage = Brokerage.new
    end

    def edit
      @brokerage = Brokerage.find(params[:id])
    end

    def update
      @brokerage = Brokerage.find(params[:id])

      if @brokerage.update(brokerage_params)
        redirect_to admin_brokerages_path, notice: 'Brokerage was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def brokerage_params
      params.require(:brokerage).permit(:name, :address, :city)
    end
  end
end
