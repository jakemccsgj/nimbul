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

  def stats_period_link(text, year, month=nil, toyear=nil, tomonth=nil)
    url = polymorphic_url([@parent, :stats])
    url += "/#{year}" unless year.nil?
    unless month.nil?
      month="0#{month}" if month < 10
      url += "/#{month}"
    end
    url += "/#{toyear}" unless toyear.nil?
    unless tomonth.nil?
      tomonth="0#{tomonth}" if tomonth < 10
      url += "/#{tomonth}"
    end

    update = :stats
    options = {
      :url => url,
      :update => update,
      :method => :get,
    }

    html_options = {
      :href => url,
      :title => text,
    }

    link_to_remote text, options, html_options
  end

  def stats_date_bar(bar_start_date, bar_end_date)
    bar_end_date ||= Date.current

    current_year = bar_end_date.year
    prev_year = current_year - 1
    year_span = {
      prev_year => 0,
      current_year => 0,
    }

    months = ''
    (1..12).each do |m|
      m_name = Date::ABBR_MONTHNAMES[m]
      klass = ''
      klass = " class='active'" if ( params[:year].to_i == prev_year and (params[:month].nil? or params[:month].to_i == m))
      months += "<td #{klass}>"+stats_period_link(m_name, prev_year, m)+"</td>"
      year_span[prev_year] = year_span[prev_year]+1
    end
    (1..bar_end_date.month).each do |m|
      m_name = Date::ABBR_MONTHNAMES[m]
      klass = ''
      klass = " class='active'" if ( params[:year].to_i == current_year and (params[:month].nil? or params[:month].to_i == m))
      months += "<td #{klass}>"+stats_period_link(m_name, current_year, m)+"</td>"
      year_span[current_year] = year_span[current_year]+1
    end

    years = ''
    (bar_start_date.year..bar_end_date.year).each do |y|
      if year_span[y].nil?
        months = '<td>&nbsp;</td>'+months
      end
      klass = ''
      klass = " class='active'" if params[:year].to_i == y
      years += "<td #{klass} colspan='#{year_span[y]}' align='center'>"+stats_period_link(y,y)+"</td>"
    end

    text = '<table>'
    text += '<tr>'+years+'</tr>'
    text += '<tr>'+months+'</tr>'
    text += '</table>'
    text
  end
end
