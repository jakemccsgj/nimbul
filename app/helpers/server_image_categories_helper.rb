module ServerImageCategoriesHelper
    def add_provider_account_server_image_category_link(text, provider_account)
        link_to_function text do |page|
            page[:add_server_image_category].hide
            page[:new_server_image_category].appear
        end
    end

    def remove_provider_account_server_image_category_link(text, parent, server_image_category)
        url = provider_account_server_image_category_url(parent, server_image_category)

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

    def new_provider_account_server_image_category_button(text, provider_account)
        url = new_provider_account_server_image_category_url(provider_account)
        options = {
            :url => url,
            :method => :get,
        }
        html_options = {
            :title => "Add Server Image Category",
            :href => url,
            :method => :get,
       }
       button_to_remote text, options, html_options
    end

    def cancel_add_provider_account_server_image_category_button(text, provider_account)
        button_to_function text do |page|
            page[:edit_server_image_category].hide
            page[:add_server_image_category].appear
        end
    end
end
