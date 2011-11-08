module InstanceVmTypesHelper
    def add_provider_instance_vm_type_link(text, provider)
        link_to_function text do |page|
            page[:add_instance_vm_type].hide
            page[:new_instance_vm_type].appear
        end
    end

    def remove_provider_instance_vm_type_link(text, parent, instance_vm_type)
        url = provider_instance_vm_type_url(parent, instance_vm_type)

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

    def new_provider_instance_vm_type_button(text, provider)
        url = new_provider_instance_vm_type_url(provider)
        options = {
            :url => url,
            :method => :get,
        }
        html_options = {
            :title => "Add VM Type",
            :href => url,
            :method => :get,
       }
       button_to_remote text, options, html_options
    end

    def cancel_add_provider_instance_vm_type_button(text, provider)
        button_to_function text do |page|
            page[:edit_instance_vm_type].hide
            page[:add_instance_vm_type].appear
        end
    end
end
