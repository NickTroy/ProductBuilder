class OptionValue < ActiveRecord::Base
  belongs_to :option
  has_many :variants_option_values, dependent: :destroy
  has_many :variants, through: :variants_option_values, dependent: :destroy
  #has_and_belongs_to_many :variants
  
  has_attached_file :image, :styles => { :medium => "300x300>",:thumb => "100x100>" }
	
	validates_attachment 	:image, 
				#:presence => true,
				:content_type => { :content_type => /\Aimage\/.*\Z/ },
				:size => { :less_than => 1.megabyte }
				
end
