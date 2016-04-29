class AddAverageAndStdDevToUser < ActiveRecord::Migration
  def up
    add_column :users, :rating_average, :float, default: 0.0
    add_column :users, :rating_standard_deviation, :float, default: 0.0

    # calculate starting values based on existing ratings
    User.all.each do |user|
      scores = Rating.select("stddev(score) as std, avg(score) as avg").group(:user_id).where(user: user)[0]
      if scores
        user.update(rating_average: scores.avg, rating_standard_deviation: scores.std)
      end
    end
  end

  def down
    remove_column :users, :rating_average
    remove_column :users, :rating_standard_deviation
  end
end
