module LaunchConfigurationsHelper
  def add_launch_configuration_link(name)
    link_to_function name do |page|
      page.insert_html :top, :launch_configuration_records, :partial => "launch_configurations/launch_configuration", :object => LaunchConfiguration.new
    end
  end

	def launch_configurations_sort_link(text, param)
    sort_link(text, param, nil, nil, :list)
  end

  def edit_launch_configuration_link(text, parent, launch_configuration)
    return '&nbsp' if launch_configuration.new_record?
    if launch_configuration.active?
      link_to text, polymorphic_path([parent, launch_configuration])
    else
      link_to text, edit_polymorphic_path([parent, launch_configuration])
    end
  end
	
	def delete_launch_configuration_link(text, parent, launch_configuration)
    return '&nbsp' if launch_configuration.new_record?
    disabled = launch_configuration.locked?() ? ' [unable to delete while active]' : ''
    url = polymorphic_url([parent, launch_configuration])
    if launch_configuration.disabled?
      options = {
        :url => url,
        :method => :delete,
        :condition => "confirm_delete_launch_configuration('#{launch_configuration.name} ?')"
      }
      html_options = {
        :title => text,
        :href => url,
        :method => :delete,
      }
      image_options = {
        :class => 'control-icon',
        :alt => "#{text}#{disabled}",
        :title => "#{text}#{disabled}"
      }
      image_options[:class] = 'control-icon-disabled' if launch_configuration.locked?

      link_text = image_tag('trash.png', image_options)

      link_to_remote link_text, options, html_options
    else
      image_tag 'trash.png', :class => 'control-icon',
        :title => 'Delete AutoScaling Group [disabled]',
        :alt => "Delete AutoScaling Group [disabled]",
        :class => 'control-icon-disabled'
    end
	end

  def toggle_active_launch_configuration_link(link_texts, parent, launch_configuration)
    return '&nbsp' if launch_configuration.new_record?
    disabled = launch_configuration.locked?() ? ' [unable to change state while Active AS Groups are using this configuration]' : ''
    if launch_configuration.active?
      text = link_texts[1]
      image = 'status-disabled.png'
      url = polymorphic_url([parent, launch_configuration], {:action => :disable})
    else
      text = link_texts[0]
      image = 'status-active.png'
      url = polymorphic_url([parent, launch_configuration], {:action => :activate})
    end

    options = {
      :url => url,
      :method => :post,
		}

    html_options = {
			:title => "#{text} Launch Configuration '#{launch_configuration.name}'",
      :href => url,
      :method => :post,
		}

    image_options = {
			:align => :absmiddle,
			:alt => "#{text} Launch Configuration '#{launch_configuration.name}'#{disabled}",
			:title => "#{text} Launch Configuration '#{launch_configuration.name}'#{disabled}"
		}
    image_options[:class] = 'control-icon-disabled' if launch_configuration.locked?
    link_text = image_tag(image, image_options)

    if launch_configuration.unlocked?
      link_to_remote link_text, options, html_options
    else
      link_text
    end
	end
end
