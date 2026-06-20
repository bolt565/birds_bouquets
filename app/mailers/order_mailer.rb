class OrderMailer < ApplicationMailer
  def order_confirmation(order)
    @order = order
    mail(to: order.email, subject: "Order Confirmed — #{order.order_number}")
  end

  def order_shipped(order)
    @order = order
    mail(to: order.email, subject: "Your Order Has Shipped — #{order.order_number}")
  end

  def order_delivered(order)
    @order = order
    mail(to: order.email, subject: "Your Order Was Delivered — #{order.order_number}")
  end
end
