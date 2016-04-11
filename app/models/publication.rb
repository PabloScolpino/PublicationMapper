class Publication < ActiveRecord::Base
  has_many :taggings
  has_many :tags, through: :taggings
  accepts_nested_attributes_for :tags

  belongs_to :icon_tag, class_name: 'Tag'

  validates :name, presence: true,
                   length: { minimum: 5 }

  scope :approved, -> { where( 'approved_at is not null and approved_at <= ?', DateTime.now() ) }

  geocoded_by :full_address
  after_validation :geocode, if: :full_address_changed?

  def full_address
    address + ', ' + locality + ', ' + province + ', ' + country
  end

  def full_address_changed?
    address_changed? || locality_changed? || province_changed? || country_changed?
  end

  def google_chart_point
    point = [ self.latitude, self.longitude, self.name ]
    if !self.icon_tag.nil?
      point << self.icon_tag.icon_name
    else
      point << nil #nil is 'default'
    end
    point
  end

  def approved?
    self.approved_at != nil && self.approved_at <= DateTime.now()

  end
end
