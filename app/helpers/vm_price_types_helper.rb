module VmPriceTypesHelper
    def add_provider_vm_price_type_link(text, provider)
        link_to_function text do |page|
            page[:add_vm_price_type].hide
            page[:new_vm_price_type].appear
        end
    end

    def remove_provider_vm_price_type_link(text, parent, vm_price_type)
        url = provider_vm_price_type_url(parent, vm_price_type)

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

    def new_provider_vm_price_type_button(text, provider)
        url = new_provider_vm_price_type_url(provider)
        options = {
            :url => url,
            :method => :get,
        }
        html_options = {
            :title => "Add VM Price Type",
            :href => url,
            :method => :get,
       }
       button_to_remote text, options, html_options
    end

    def cancel_add_provider_vm_price_type_button(text, provider)
        button_to_function text do |page|
            page[:edit_vm_price_type].hide
            page[:add_vm_price_type].appear
        end
    end
end
