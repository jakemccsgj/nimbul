module LoadBalancersHelper
    def add_provider_account_load_balancer_link(text, provider_account)
        link_to_function text do |page|
            page[:add_load_balancer].hide
            page[:new_load_balancer].appear
        end
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
