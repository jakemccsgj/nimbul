module ServerImagesHelper
    def server_images_sort_link(text, param)
        sort_link(text, param, nil, nil, :list)
    end

    def add_server_image_link(text)
        url = new_provider_account_server_image_path(@provider_account)
        link_text = image_tag("add.png", :class => 'control-icon', :alt => text)
		options = {
			:url => url,
			:method => :get,
		}
		html_options = {
		    :href => url,
		    :method => :get,
		}
        link_to_remote link_text, options, html_options
    end

    def add_server_image_button(text)
        html_options = {
            :class => 'control-icon',
            :alt => text,
            :title => 'Add / Register a Server Image',
        }
        link_text = image_tag 'add.png', html_options
        add_server_image_link link_text
    end

    def remove_server_image_submit(text)
        empty_selection_msg = "Please select images to deregister."
        confirm_msg = 'Are you sure?\n\nAll selected images will be deregistered.\nThis cannot be undone.'
        html_options = {
            :name => 'destroy',
            :alt => text,
            :class => 'control-icon',
            :title => "Deregister Selected Images",
            :onclick => "return confirm_multiple_action(this, '.command', 'release', '#{empty_selection_msg}', '#{confirm_msg}');", 
        }
        image_submit_tag 'trash.png', html_options
    end

    def enable_server_images_submit(text)
        empty_selection_msg = "Please select server images to enable."
        html_options = {
            :name => 'enable',
            :alt => text,
            :class => 'control-icon',
            :title => "Enable Selected Server Images",
            :onclick => "return confirm_multiple_action(this, '.command', 'enable', '#{empty_selection_msg}');", 
        }
        image_submit_tag 'enable.png', html_options
    end

    def disable_server_images_submit(text)
        empty_selection_msg = "Please select server images to disable."
        confirm_msg = 'Are you sure?\n\nAll selected server images will be hidden.\nThey will no longer be available under server profiles.'
        html_options = {
            :name => 'disable',
            :alt => text,
            :class => 'control-icon',
            :title => "Disable Selected Server Images",
            :onclick => "return confirm_multiple_action(this, '.command', 'disable', '#{empty_selection_msg}', '#{confirm_msg}');", 
        }
        image_submit_tag 'disable.png', html_options
    end

    def show_hide_server_image_server_profile_revisions_link(server_image, show = 'show', hide = 'hide')
        expand_span_id = "expand_server_image_#{server_image.id}_server_profile_revisions"
        compress_span_id = "compress_server_image_#{server_image.id}_server_profile_revisions"
        server_profile_revisions_row_id = "server_image_#{server_image.id}_server_profile_revisions_row"

        html_options = {
            :class => 'bare-link',
        }

        link_text = "<small><br/>" + server_image.server_profile_revisions.count.to_s + " total server profiles(#{show})</small>"
        options = {
            :url => server_image_server_profile_revisions_path(server_image),
            :method => :get,
            :success => "$('#{expand_span_id}').hide(); $('#{compress_span_id}').show(); $('#{server_profile_revisions_row_id}').show();",
        }
        show_link = link_to_remote link_text, options, html_options

        link_text = "<small><br/>" + server_image.server_profile_revisions.count.to_s + " total server profiles (#{hide})</small>"
        js_function1 = "$('#{compress_span_id}').hide(); $('#{expand_span_id}').show(); $('#{server_profile_revisions_row_id}').innerHTML = '';"
        js_function = "$('#{compress_span_id}').hide(); $('#{expand_span_id}').show(); $('#{server_profile_revisions_row_id}').hide();"
        hide_link = link_to_function link_text, js_function, html_options

        result = content_tag(:span, show_link, { :id => expand_span_id })
        result += content_tag(:span, hide_link, { :id => compress_span_id, :style => 'display:none;' })
        return result
    end    
end
