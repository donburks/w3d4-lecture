class Store < ActiveRecord::Base
  belongs_to :mall

  validates :name, presence: true
  validates :category, presence: true
  validate :not_over_capacity, if: :mall

  after_create :increase_revenue, if: :mall

  def increase_revenue
    mall.revenue += 1000
    mall.save
  end

  def not_over_capacity
   errors[:capacity] = "too many stores" if mall.stores.count >= mall.capacity
  end
end