module RegionsHelper
    def add_provider_region_link(text, provider)
        link_to_function text do |page|
            page[:add_region].hide
            page[:new_region].appear
        end
    end

    def remove_provider_region_link(text, parent, region)
        url = provider_region_url(parent, region)

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

    def new_provider_region_button(text, provider)
        url = new_provider_region_url(provider)
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

    def cancel_add_provider_region_button(text, provider)
        button_to_function text do |page|
            page[:edit_region].hide
            page[:add_region].appear
        end
    end
end
