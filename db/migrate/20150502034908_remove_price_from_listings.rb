class RemovePriceFromListings < ActiveRecord::Migration
  def change
    remove_column :listings, :price, :decimal
  end
end
