class Spree::SubscriptionMailer < Spree::BaseMailer
  def reminder_email(sub)
    @sub = sub.respond_to?(:id) ? sub : Spree::Subscription.find(sub)
    @user = sub.user
    subject = "#{Spree::Store.current.name} Your Next Order is Due Soon"
    @sub.update_attribute(:reminded_at, Time.now)
    mail(to: @user.email, from: 'sales@subsupps.co.nz', subject: subject)
  end
end