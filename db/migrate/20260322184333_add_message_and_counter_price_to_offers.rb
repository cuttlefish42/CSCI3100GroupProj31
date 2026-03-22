class AddMessageAndCounterPriceToOffers < ActiveRecord::Migration[8.1]
  def change
    add_column :offers, :message, :text
    add_column :offers, :counter_price, :decimal
  end
end
