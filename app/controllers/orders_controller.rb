class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  def sales
    @orders = Order.all.where(seller: current_user).order("created_at DESC")
  end


  def purchases
    @orders = Order.all.where(buyer: current_user).order("created_at DESC")
  end

  # GET /orders/new
  def new
    @order = Order.new
    @listing = Listing.find(params[:listing_id])
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    @listing = Listing.find(params[:listing_id])
    @order.seller_id = @listing.user.id
    @order.listing_id = @listing.id
    @order.buyer_id = current_user.id

    Stripe.api_key = Rails.application.secrets.STRIPE_API_KEY
    token = params[:stripeToken]
    begin
      charge = Stripe::Charge.create(
        #convert to cents for proper conversion
        :amount => (@listing.price * 100).floor,
        :currency => "usd",
        :card => token)
      flash[:notice] = "Thanks For Ordering!"
    rescue Stripe::CardError => e
      flash[:danger] = e.message
    end
    respond_to do |format|
      if @order.save
        format.html { redirect_to root_url, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:address, :city, :state)
    end
end
