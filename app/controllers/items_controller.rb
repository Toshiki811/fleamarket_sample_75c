class ItemsController < ApplicationController
  before_action :set_parents, only: [:index, :new, :create]
  before_action :set_item, only: [:show, :purchase, :pay, :card_show]
  before_action :set_card, only: [:purchase, :pay, :card_show]
略
  def show
    @items = Item.includes(:item_imgs).where(id: params[:id])
    @item = Item.find_by(id: params[:id])
    @category_grandchild = Category.find_by(id: @item.category_id)
    @category_child = @category_grandchild.parent
    @category_parent = @category_child.parent
  end
  
  def purchase
    Payjp.api_key = Rails.application.credentials[:payjp_private_key]
    if not @card.blank?
      customer = Payjp::Customer.retrieve(@card.customer_id)
      @default_card_information = customer.cards.retrieve(@card.card_id)
    end
  end

  def pay
    Payjp.api_key = Rails.application.credentials[:payjp_private_key]
    Payjp::Charge.create(
      :amount => @item.price, #支払金額を入力（itemテーブル等に紐づけても良い）
      :customer => @card.customer_id, #顧客ID
      :currency => 'jpy', #日本円
    )
    @item.trading_status = 1
    @item.buyer_id = current_user.id
    @item.save
    redirect_to action: :done
  end

  def done
  end

  def set_item
    @item = Item.find_by(id:params[:id])
  end

  def set_card
    @card = Card.find_by(user_id: current_user.id)
  end

  private
  def set_parents
    @parents = Category.where(ancestry: nil)
  end

  def item_params
    params.require(:item).permit(
      :name,            :introduction,              :category_id, 
      :brand_id,        :item_condition_id,         :postage_payer_id,
      :prefecture_code, :preparation_day_id,        :postage_type_id,
      :price,           :item_imgs_attributes:[:url]
    )
  end
end
