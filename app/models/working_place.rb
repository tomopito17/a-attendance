class WorkingPlace < ApplicationRecord
   #belongs_to :user
    validates :working_place_number, numericality: { only_integer: true }
end
