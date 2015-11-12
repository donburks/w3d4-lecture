class Mall < ActiveRecord::Base
  has_many :stores, dependent: :destroy

  validates :name, 
    presence: true, 
    length: {minimum: 5}
  validates :city, 
    presence: true

  # before_destroy :nuke_stores
  # after_destroy :nuke_stores, prepend: true

  def nuke_stores
    stores.destroy_all
  end
end