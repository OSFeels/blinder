class Rating < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :user

  validates :proposal, presence: true
  validates :user, presence: true
  validates :score, numericality: {
    only_integer: true,
    less_than_or_equal_to: 5,
    greater_than_or_equal_to: 0
  }

  after_save :update_user_rating_data

  def z_score
    return 0 unless user.rating_standard_deviation
    (score - user.rating_average) / user.rating_standard_deviation
  end

  private

  def update_user_rating_data
    # get updated average & std dev for the user's scores
    scores = Rating.select("stddev(score) as std, avg(score) as avg").group(:user_id).where(user: user)[0]
    
    # store those calculated values in the denormalized columns
    user.update(rating_average: scores.avg, rating_standard_deviation: scores.std)

    # calculate the associated Proposal's new z_score average
    z_avg = proposal.ratings.to_a.sum(&:z_score) / proposal.ratings.length

    # store the calculated z_avg in the denormalized column
    proposal.update(z_average: z_avg)
  end
end
