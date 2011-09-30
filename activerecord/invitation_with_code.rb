require 'digest/sha1'

class Invitation < ActiveRecord::Base

  belongs_to :user
  belongs_to :someone

  validates :user_id, :presence => true
  validates :code, :presence => true

  before_validation :generate_code, :on => :create

  scope :unused, where("someone_id is null")

  def used?
    self.someone_id.present?
  end

  def self.exists_unused_code?(code)
    unused.exists?(:code => code)
  end

  private

  def generate_code
    self.code = Digest::SHA1.hexdigest("#{Time.now}--#{rand(1000)}--#{self.class.name}")[0..15].upcase
  end

end
