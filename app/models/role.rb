class Role < ActiveRecord::Base
  has_many :users_roles
  has_many :users, :through => :users_roles
  validates :name, uniqueness: { :case_sensitive => false }
end
