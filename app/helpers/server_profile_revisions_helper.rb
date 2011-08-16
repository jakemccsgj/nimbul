module ServerProfileRevisionsHelper
    def remove_server_profile_revision_link(text, parent, server_profile_revision)
        url = polymorphic_url([parent, server_profile_revision])
        confirm = 'Are you sure?'
        link_text = image_tag("trash.png", :class => 'control-icon', :alt => text)

        if server_profile_revision.servers.empty?
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
        else
            options = {
                :url => '#',
            }
            html_options = {
                :title => text,
                :href => '#',
                :onclick => 'alert("This Server Profile has Server(s) associated with it.\n\nPlease associate the Server(s) with a another Server Profile before removing this Server Profile."); return false;',
            }
        end

        link_to_remote link_text, options, html_options
    end
end
