module ApplicationHelper
  def item_status_badge_class(item)
    case item.status
    when "available" then "badge-success text-success-content"
    when "reserved"  then "badge-warning text-warning-content"
    when "sold"      then "badge-neutral text-neutral-content"
    else "badge-ghost"
    end
  end

  def sortable_header(label, sort_key, current_sort, current_dir, sort_param: "sort", dir_param: "dir", **extra_params)
    new_dir = (current_sort == sort_key && current_dir == "asc") ? "desc" : "asc"
    arrow = if current_sort == sort_key
              current_dir == "asc" ? " ▲" : " ▼"
    else
              ""
    end
    link_to("#{label}#{arrow}".html_safe, request.params.merge(sort_param => sort_key, dir_param => new_dir, **extra_params))
  end



  def price(amount)
    number_to_currency(amount)
  end

  def offer_status_text(offer)
    text = offer.status.humanize
    if offer.countered? && offer.counter_price.present?
      text += " (#{price(offer.counter_price)})"
    end
    text
  end

  def time_ago(time)
    return "Never" if time.blank?

    "#{time_ago_in_words(time)} ago"
  end
end
