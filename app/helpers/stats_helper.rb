module StatsHelper
  def stats_sort_link(text, param)
    sort_link(text, param, :stats, nil, :index)
  end

  def parent_stats_link(text, parent)
    url = polymorphic_url([parent, :stats])

    link_text = image_tag("system-search.png", :class => 'control-icon', :alt => text)

    html_options = {
      :title => text
    }

    link_to link_text, url, html_options
  end

  def parent_stats_js(parent)
    url = polymorphic_url([:total, parent, :stats])

    javascript_tag(remote_function(:url => url, :method => :get) )
  end
end
