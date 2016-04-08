class User < ActiveRecord::Base
  before_save :default_values
  def default_values
    self.update_attributes(:admin => false) if self.admin == nil
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :omniauthable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  validates :firstname, :lastname, :email, :age, presence: true
  
  # Friendships with other users
  has_many :requesting_friendships, class_name: "Friendship", foreign_key: :requestee_id, dependent: :destroy
  has_many :requested_friendships, class_name: "Friendship", foreign_key: :requester_id, dependent: :destroy
  has_many :requesting_friends, through: :requesting_friendships, source: :requester
  has_many :requested_friends, through: :requested_friendships, source: :requestee
  include UserMethods::Relationships

  # Likes and author of posts
  has_many :authored_posts, class_name: "Post", foreign_key: :author_id, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post

  has_many :comments, foreign_key: :author_id
  
  def has_liked?(post)
    liked_posts.any? { |p| p.id == post.id }
  end


  def admin?
    self.admin
  end

  def name
  	[firstname, lastname].join(' ')
  end
  
end

