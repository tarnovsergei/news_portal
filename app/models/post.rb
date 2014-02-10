class Post < ActiveRecord::Base
  include TheComments::Commentable
  has_and_belongs_to_many :categories
  belongs_to :user
  validates :user_id,     presence: true
  validates :title,       presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 400 }
  validates :content,     presence: true, length: { maximum: 4000 }

  # "subscription_mailer" fetches the users who need to send a mail
  # I think that this code smells. I will do that later.
  def subscription_mailer
    user_ids = Subscription.where('category_id in (?)', self.categories.ids).distinct.pluck(:user_id)
    subscribed_users = User.find(user_ids)
    subscribed_users.each do |user|
      UserMailer.delay.subscription(user.id, self.id)
    end
  end

  # Denormalization methods
  def commentable_title
    "Undefined Post Title"
  end

  def commentable_url
    "#"
  end

  def commentable_state
    "published"
  end
end
