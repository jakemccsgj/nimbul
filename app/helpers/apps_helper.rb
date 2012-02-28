module AppsHelper
    def add_account_group_app_link(text, account_group)
        link_to_function text do |page|
            page[:add_app].hide
            page[:new_app].appear
        end
    end

    def remove_account_group_app_link(text, parent, app)
        url = account_group_app_url(parent, app)

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

    def new_account_group_app_button(text, account_group)
        url = new_account_group_app_url(account_group)
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

    def cancel_add_account_group_app_button(text, account_group)
        button_to_function text do |page|
            page[:edit_app].hide
            page[:add_app].appear
        end
    end
end
