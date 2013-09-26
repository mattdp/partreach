class UserMailer < ActionMailer::Base
  default from: "noreply@supplybetter.com"
  include SessionsHelper

  MATT = "matt@supplybetter.com"
  ROB =   "rob@supplybetter.com"
  EMPLOYEES = [MATT,ROB]

  def email_internal_team(subject, note)
    @note = note
    EMPLOYEES.each do |e|
      mail(to: e, subject: subject).deliver
    end
  end

  def daily_internal_update()
    subject = "#{Date.today.strftime('%Y-%m-%d')} update on SupplyBetter metrics"
    @pending = {
      "reviews" => Review.pending_examination,
      "suppliers" => Supplier.pending_examination
    }
    @incomplete_orders = Order.incomplete_orders
    @brand_name = brand_name
    EMPLOYEES.each do |e|
      mail(to: e, subject: subject).deliver
    end
  end

  def welcome_email(user)
  	@user = user
    @brand_name = brand_name
  	@url = Rails.env.production? ? "http://www.supplybetter.com" : "http://localhost:3000"
  	mail(to: @user.email, subject: "Welcome to #{brand_name}")
  end

  #VET THIS - think it's broken
  def bid_completed_email(user,order)
  	@user = user
  	@order = order
  	@url = orders_path(order)
  	mail(to: @user.email, subject: "Your #{brand_name} quotes have arrived")
  end

  def password_reset(user)
    @user = user
    @brand_name = brand_name
    mail(to: @user.email, subject: "Password reset requested")
  end

  def supplier_intro_email(user,supplier)
    @user = user
    @brand_name = brand_name
    @supplier = supplier
    mail(to: @user.email, subject: "Your new #{brand_name} account")
  end

end
