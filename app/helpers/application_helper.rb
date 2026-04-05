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
end
