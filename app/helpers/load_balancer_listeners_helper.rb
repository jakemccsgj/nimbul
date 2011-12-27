module LoadBalancerListenersHelper
  def add_load_balancer_listener_link(text)
    link_to_function text do |page|
      page.insert_html :bottom, :load_balancer_listeners,
        :partial => 'load_balancer_listeners/load_balancer_listener',
        :object => LoadBalancerListener.new
    end
  end
end
