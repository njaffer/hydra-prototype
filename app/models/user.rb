class User < ActiveRecord::Base
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles


  # Connects this user object to Curation Concerns behaviors.
  include CurationConcerns::User

  # :groups is defined by CurationConcerns::User.groups
  has_and_belongs_to_many :user_groups, class_name: 'Group'

  def has_role?(role)
    self.roles.where(name: role).exists? or has_group_role?(role)
  end

  def has_group?(group)
    # self.groups.where(name: group).exists?
    not(self.groups.index(group).nil?)
  end

  def has_group_role?(role)
    user_groups.joins(:roles).where('roles.name' => role).exists?
  end
  
  def groups
    # for reals?
    user_groups.collect { |g| g.name }
  end

  def admin?
    roles.where(name: 'admin').exists? or has_group_role?('admin')
  end


  if Blacklight::Utils.needs_attr_accessible?

    attr_accessible :email, :password, :password_confirmation
  end
# Connects this user object to Blacklights Bookmarks. 
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end
end
