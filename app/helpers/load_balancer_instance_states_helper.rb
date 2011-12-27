module LoadBalancerInstanceStatesHelper
  def add_load_balancer_instance_link(text, load_balancer, instance)
    link_text = image_tag("add.png", :class => 'small-icon', :title => text)
#    if load_balancer.new_record?
      lbis = LoadBalancerInstanceState.new
      lbis.instance = instance
      link_to_function link_text do |page|
        page.insert_html :bottom, :load_balancer_instances,
          :partial => 'load_balancer_instance_states/load_balancer_instance_state',
          :object => lbis
        page["instance_#{instance.id}"].hide
      end 
#    else
#      url = load_balancer_instances_url(load_balancer)
#      options = {
#        :url => url,
#        :method => :put,
#        :with => "'instance_id=#{instance.id}'"
#      }
#      html_options = {
#        :title => text,
#        :href => url,
#        :method => :put,
#      }
#      link_to_remote link_text, options, html_options
#    end
  end

  def remove_load_balancer_instance_link(text, load_balancer, instance)
    link_text = image_tag("contract.png", :class => 'small-icon', :title => text)
#    if load_balancer.new_record?
      link_to_function link_text do |page|
        page << "$(this).up('.load_balancer_instance_state').remove();"
      end
#    else
#      url = load_balancer_instance_url(load_balancer, instance)
#
#      confirm = "Are you sure?"
#      options = {
#        :confirm => confirm,
#        :url => url,
#        :method => :delete,
#      }
#      html_options = {
#        :title => text,
#        :href => url,
#        :method => :delete,
#      }
#      link_to_remote link_text, options, html_options
#    end
  end
end
