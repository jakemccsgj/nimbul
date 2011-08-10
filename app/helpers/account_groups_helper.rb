module AccountGroupsHelper
    def add_account_group_link(text)
        link_to_function text do |page|
            page[:add_account_group].hide
            page[:new_account_group].appear
        end
    end

    def remove_account_group_link(text, account_group)
        url = account_group_url(account_group)

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

    def new_account_group_button(text)
        url = new_account_group_url
        options = {
            :url => url,
            :method => :get,
        }
        html_options = {
            :title => "Add Account Group",
            :href => url,
            :method => :get,
       }
       button_to_remote text, options, html_options
    end

    def cancel_add_account_group_button(text)
        button_to_function text do |page|
            page[:edit_account_group].hide
            page[:add_account_group].appear
        end
    end
end
