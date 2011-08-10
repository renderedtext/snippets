class Building < ActiveRecord::Base

  has_many :apartments

  def rats
    Rat.for_building(self)
  end

end

class Apartment < ActiveRecord::Base

  belongs_to :building
  has_many :rats

end

class Rat < ActiveRecord::Base

  belongs_to :apartment

  scope :for_building, lambda { |building|
    joins(:apartment => :building).where("buildings.id" => building.id)
  }

end

# get all rats in the building

building = Building.last

rats = building.rats

# you can also get count of rats which will only perform COUNT(*)

count = building.rats.count
