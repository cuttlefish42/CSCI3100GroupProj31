module ConversationsHelper
  def offer_status_badge_class(offer)
    case offer.status
    when "pending", "countered" then "badge-warning"
    when "accepted" then "badge-success"
    when "rejected" then "badge-error"
    else "badge-ghost"
    end
  end
end
