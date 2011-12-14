module LoadBalancerInstanceStatesHelper
  def add_load_balancer_instance_link(text, instance)
    link_text = image_tag("add.png", :class => 'small-icon', :title => text)
    lbis = LoadBalancerInstanceState.new
    lbis.instance = instance
    link_to_function link_text do |page|
      page.insert_html :bottom, :load_balancer_instances, :partial => 'load_balancer_instance_states/load_balancer_instance_state', :object => lbis
      page["instance_#{instance.id}"].hide
    end    
  end

  def remove_load_balancer_instance_link(text, load_balancer_instance_state)
    link_text = image_tag("contract.png", :class => 'small-icon', :title => text)
    if load_balancer_instance_state.new_record?
      link_to_function link_text do |page|
        page << "$('instance_#{load_balancer_instance_state.instance_id}').show();"
        page << "$(this).up('.load_balancer_instance_state').remove();"
      end
    else
      link_to_function link_text, "mark_for_destroy(this, $(this).up('.load_balancer_instance_state'))"      
    end
  end
end
