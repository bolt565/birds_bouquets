module ApplicationHelper
  include SeoHelper

  def flash_class(type)
    case type.to_sym
    when :notice then "bg-sage-pale/60 border-sage text-moss"
    when :alert  then "bg-blush border-blush-deep text-ink"
    else "bg-linen border-sage-pale text-ink"
    end
  end

  def order_status_color(status)
    case status
    when "pending", "payment_pending" then "text-yellow-600 bg-yellow-50"
    when "paid"                       then "text-blue-600 bg-blue-50"
    when "processing"                 then "text-purple-600 bg-purple-50"
    when "shipped"                    then "text-indigo-600 bg-indigo-50"
    when "delivered"                  then "text-green-600 bg-green-50"
    when "cancelled", "refunded"      then "text-red-600 bg-red-50"
    else "text-gray-600 bg-gray-50"
    end
  end

  def format_cents(cents)
    number_to_currency(cents / 100.0)
  end
end
