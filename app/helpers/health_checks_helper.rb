module HealthChecksHelper
    def add_load_balancer_health_check_link(text, load_balancer)
        link_to_function text do |page|
            page[:add_health_check].hide
            page[:new_health_check].appear
        end
    end

    def edit_load_balancer_health_check_link(text, parent, health_check)
        url = edit_load_balancer_health_check_url(parent, health_check)

        link_text = image_tag("edit-find-replace.png", :class => 'control-icon', :alt => text)

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

    def remove_load_balancer_health_check_link(text, parent, health_check)
        url = load_balancer_health_check_url(parent, health_check)

        confirm = "Are you sure?"
        link_text = image_tag("trash.png", :class => 'control-icon', :alt => text)

        options = {
            :confirm => confirm,
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

    def new_load_balancer_health_check_button(text, load_balancer)
        url = new_load_balancer_health_check_url(load_balancer)
        options = {
            :url => url,
            :method => :get,
        }
        html_options = {
            :title => "Add Health Check",
            :href => url,
            :method => :get,
       }
       button_to_remote text, options, html_options
    end

    def cancel_add_load_balancer_health_check_button(text, load_balancer)
        button_to_function text do |page|
            page[:edit_health_check].hide
            if load_balancer.can_use_more_of?('HealthCheck')
                page[:add_health_check].appear
            end
        end
    end
end
