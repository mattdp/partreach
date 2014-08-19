class OrderTransferor

  def initialize(order)
    @order = order
  end

  def transfer(new_email)
    contact = Contact.find_by_email(new_email) 
    if contact && contact.contactable && contact.contactable.user
      user_id = contact.contactable.user.id
    else
      user = User.create_with_dummy_password('<Enter Name>', new_email)
      user.send_password_reset
      user_id = user.id
    end
    @order.update_column('user_id', user_id)
    @order
  end

end