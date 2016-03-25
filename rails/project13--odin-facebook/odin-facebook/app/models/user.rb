class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :omniauthable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  validates :firstname, :lastname, :email, :age, presence: true
  

  def name
  	[firstname, lastname].join(' ')
  end
end
