module LoadBalancerListenersHelper
  def add_load_balancer_listener_link(text, load_balancer)
    if load_balancer.new_record?
      link_to_function text do |page|
        page.insert_html :bottom, :load_balancer_listeners, :partial => 'load_balancer_listeners/load_balancer_listener', :object => LoadBalancerListener.new
      end
    else
      link_to_function text do |page|
        page[:add_load_balancer_listener].hide
        page[:new_load_balancer_listener].appear
      end
    end
  end

  def cancel_add_load_balancer_listener_button(text, load_balancer)
    button_to_function text do |page|
      page[:new_load_balancer_listener].hide
      page[:add_load_balancer_listener].appear
    end
  end
end
