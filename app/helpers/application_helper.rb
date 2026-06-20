module ApplicationHelper
  include SeoHelper

  def flash_class(type)
    case type.to_sym
    when :notice then "bg-green-50 border-green-200 text-green-800"
    when :alert  then "bg-red-50 border-red-200 text-red-800"
    else "bg-blue-50 border-blue-200 text-blue-800"
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
