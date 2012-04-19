module StorageTypesHelper
    def add_provider_storage_type_link(text, provider)
        link_to_function text do |page|
            page[:add_storage_type].hide
            page[:new_storage_type].appear
        end
    end

    def remove_provider_storage_type_link(text, parent, storage_type)
        url = provider_storage_type_url(parent, storage_type)

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

    def new_provider_storage_type_button(text, provider)
        url = new_provider_storage_type_url(provider)
        options = {
            :url => url,
            :method => :get,
        }
        html_options = {
            :title => "Add Storage Type",
            :href => url,
            :method => :get,
       }
       button_to_remote text, options, html_options
    end

    def cancel_add_provider_storage_type_button(text, provider)
        button_to_function text do |page|
            page[:edit_storage_type].hide
            page[:add_storage_type].appear
        end
    end
end
