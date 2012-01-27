module LoadBalancersHelper
  def load_balancers_sort_link(text, param)
    sort_link(text, param, nil, nil, :list)
  end

  def add_provider_account_load_balancer_link(text, provider_account)
    link_text = image_tag("add.png", :class => 'control-icon', :alt => text)
		url = new_provider_account_load_balancer_url(provider_account)
    options = {
      :url => url,
      :method => :get,
    }
    html_options = {
      :title => "Add Elastic Load Balancer",
      :href => url,
      :method => :get,
    }
    link_to_remote link_text, options, html_options
  end

  def edit_provider_account_load_balancer_link(text, parent, load_balancer)
    url = edit_provider_account_load_balancer_url(parent, load_balancer)

    #link_text = image_tag("verify.png", :class => 'control-icon', :alt => text)
    link_text = h(load_balancer.load_balancer_name)

    options = {
      :url => url,
      :method => :get,
    }
    html_options = {
      :title => text,
      :href => url,
      :method => :get,
    }
    link_to_remote link_text, options, html_options
  end

  def remove_provider_account_load_balancer_link(text, parent, load_balancer)
    url = provider_account_load_balancer_url(parent, load_balancer)

    message1 = '\nAre you sure?\n\nRemoving the load balancer will most likely cause a service disruption. It cannot be undone.\n'
    answer = 'okidoki'
    message2 = '\nPlease type '+answer+' in order to continue.\n'
    link_text = image_tag("trash.png", :class => 'control-icon', :alt => text)

    options = {
      :condition => 'double_confirm("'+message1+'","'+message2+'","'+answer+'")',
      :url => url,
      :method => :delete,
    }
    html_options = {
      :title => text,
      :href => url,
      :method => :delete,
    }
    link_to_remote link_text, options, html_options
  end

  def new_provider_account_load_balancer_button(text, provider_account)
    url = new_provider_account_load_balancer_url(provider_account)
    options = {
      :url => url,
      :method => :get,
    }
    html_options = {
      :title => "Add Load Balancer",
      :href => url,
      :method => :get,
    }
    button_to_remote text, options, html_options
  end

  def cancel_add_provider_account_load_balancer_button(text, provider_account)
    button_to_function text do |page|
      page[:edit_load_balancer].hide
      page[:add_load_balancer].appear
    end
  end
end
