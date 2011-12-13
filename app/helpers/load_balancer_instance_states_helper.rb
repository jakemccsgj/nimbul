module LoadBalancerInstanceStatesHelper
    def load_balancer_instance_state_details(lbis)
        return 'Unknown' if lbis.nil?
        toggle_id = "load_balancer_instance_state_more_#{lbis.id}"
        html = lbis.state+' '
        html += link_to_function("<sub>(more details)</sub>", "$('#{toggle_id}').toggle()")
        html += "<div id=\""+toggle_id+"\" style='display: none;'>"
        html += "Because of #{h(lbis.reason_code)}: #{h(lbis.description)}"
        html += "</div>"
        return html
    end
end
