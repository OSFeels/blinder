class AddZAvgToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :z_average, :float, default: 0.0
  end
end
