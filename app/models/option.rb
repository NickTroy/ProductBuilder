class Option < ActiveRecord::Base
  has_many :option_values, dependent: :destroy
  has_many :products_options, dependent: :destroy
  belongs_to :option
  after_create :update_order
  after_destroy :update_order
  private

  def update_order
    Option.all.order(:order_number).each_with_index do |option, i|
      option.update_attributes(:order_number =>  (i + 1))
    end
  end
end
