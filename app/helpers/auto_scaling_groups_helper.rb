module AutoScalingGroupsHelper
	ApplicationHelper.setup_methods_for_subordinate 'auto_scaling_group', :instances, 'computer', nil, nil, 'index'
	ApplicationHelper.setup_methods_for_subordinate 'auto_scaling_group', :triggers, 'gauge-green'

  def add_auto_scaling_group_link(name)
    link_to_function name do |page|
      page.insert_html :top, :auto_scaling_group_records, :partial => "auto_scaling_groups/auto_scaling_group", :object => LaunchConfiguration.new
    end
  end

	def auto_scaling_groups_sort_link(text, param)
    sort_link(text, param, nil, nil, :list)
  end

  def edit_auto_scaling_group_link(text, parent, auto_scaling_group)
    return '&nbsp' if auto_scaling_group.new_record?
    if auto_scaling_group.active?
      link_to text, polymorphic_path([parent, auto_scaling_group])
    else
      link_to text, edit_polymorphic_path([parent, auto_scaling_group])
    end
  end

	def delete_auto_scaling_group_link(text, parent, auto_scaling_group)
    return '&nbsp' if auto_scaling_group.new_record?
    url = polymorphic_url([parent, auto_scaling_group])
    if auto_scaling_group.disabled?
      options = {
        :url => url,
        :method => :delete,
        :condition => "confirm_delete_auto_scaling_group('#{auto_scaling_group.name} ?')"
      }
      html_options = {
        :title => text,
        :href => url,
        :method => :delete,
      }
      image_options = {
        :class => 'control-icon',
        :alt => "#{text}",
        :title => "#{text}"
      }
      
      link_text = image_tag('trash.png', image_options)

      link_to_remote link_text, options, html_options
    else
      image_tag 'trash.png', :class => 'control-icon-disabled',
        :title => 'Delete AutoScaling Group [disabled]', :alt => "Delete AutoScaling Group [disabled]"
    end
	end

  def toggle_active_auto_scaling_group_link(link_texts, parent, auto_scaling_group)
    return '&nbsp' if auto_scaling_group.new_record?
    condition = nil
    if auto_scaling_group.active?
      text = link_texts[1]
      image = 'status-disabled.png'
      url = polymorphic_url([parent, auto_scaling_group], {:action => :disable})
      confirm_msg = 'WARNING\n\n'
      confirm_msg += 'Disabling this Auto Scaling Group will\n'
      confirm_msg += 'TERMINATE ALL Instances in this Group\n\n'
      confirm_msg += 'Are you sure you want to disable this Group?'
      prompt_msg = 'CONFIRMATION\n\nALL Instances in this Group will be TERMINATED\n\nType yes to proceed and disable the Group:'
      condition = "confirm('#{confirm_msg}') && ('yes' == prompt('#{prompt_msg}'))"
    else
      text = link_texts[0]
      image = 'status-active.png'
      url = polymorphic_url([parent, auto_scaling_group], {:action => :activate})
      size = [auto_scaling_group.min_size, auto_scaling_group.desired_capacity].max
      if size > 0
        confirm_msg = 'WARNING\n\nActivating this Group will start ' + size.to_s + ' instance'
        confirm_msg += 's' if size > 1
        confirm_msg += '\n'
        confirm_msg += 'Are you sure you want to proceed?'
        condition = "confirm('#{confirm_msg}')"
      end
    end

    options = {
      :url => url,
      :method => :post,
      :condition => condition
		}

    html_options = {
			:title => "#{text} Auto Scaling Group '#{auto_scaling_group.name}'",
      :href => url,
      :method => :post,
		}

    image_options = {
			:align => :absmiddle,
			:alt => "#{text} Auto Scaling Group '#{auto_scaling_group.name}'",
			:title => "#{text} Auto Scaling Group '#{auto_scaling_group.name}'"
		}
    link_text = image_tag(image, image_options)

    if auto_scaling_group.disabling?
      image_options[:class] = 'control-icon-disabled'
      image_tag(image, image_options)
    else
      link_to_remote link_text, options, html_options
    end
	end

	def auto_scaling_group_numeric_parameter(parent, auto_scaling_group, par, options={})
		step = options[:step] || 1
		min_value = options[:min_value] || 0
		max_value = options[:max_value]
		unit = options[:unit]
		msg = options[:message]
		
		url = polymorphic_url([parent, auto_scaling_group])
		curr_val = auto_scaling_group.send(par)
		
		new_val = (curr_val > min_value) ? (curr_val-step) : 0
		new_val = (new_val > min_value) ? new_val : min_value
		if curr_val > min_value
			link_text = image_tag 'less.png', :class => 'control-icon'
			ajax_options = {
				:url => url,
				:method => :put,
				:with => "'auto_scaling_group[#{par.to_s}]=#{new_val}'",
			}
			html_options = {
				:title => "decrease to #{new_val}",
				:href => url,
				:method => :put,
			}
			less_link = link_to_remote link_text, ajax_options, html_options
		else
			less_link = image_tag 'less.png', :class => 'control-icon-disabled', :title => (msg || "already at #{min_value}")
		end

		if max_value.nil? or (curr_val < max_value)
			new_val = curr_val + step
			new_val = (max_value.nil? or new_val < max_value) ? new_val : max_value
			link_text = image_tag 'more.png', :class => 'control-icon'
			ajax_options = {
				:url => url,
				:method => :put,
				:with => "'auto_scaling_group[#{par.to_s}]=#{new_val}'",
			}
			html_options = {
				:title => "increase to #{new_val}",
				:href => url,
				:method => :put,
			}
			more_link = link_to_remote link_text, ajax_options, html_options
		else
			more_link = image_tag 'more.png', :class => 'control-icon-disabled', :title => (msg || "already at #{max_value}")
		end
		
		r = less_link
		r += curr_val.to_s
		r += ' '+unit unless unit.blank?
		r += more_link
		return r
	end
	
	def auto_scaling_group_min_size(parent, auto_scaling_group)
		auto_scaling_group_numeric_parameter(parent, auto_scaling_group, :min_size)
	end
	
	def auto_scaling_group_max_size(parent, auto_scaling_group)
		auto_scaling_group_numeric_parameter(parent, auto_scaling_group, :max_size)
	end
	
	def auto_scaling_group_desired_capacity(parent, auto_scaling_group)
		options ={
			:min_value => auto_scaling_group.min_size,
			:max_value => auto_scaling_group.max_size,
			:message => "Desired Capacity must be between Minimum and Maximum Size (#{auto_scaling_group.min_size} and #{auto_scaling_group.max_size})"
		}
		auto_scaling_group_numeric_parameter(parent, auto_scaling_group, :desired_capacity, options)
	end
	
	def auto_scaling_group_cooldown(parent, auto_scaling_group)
		options = {
			:step => 30,
			:max_value => 86400,
			:unit => 'sec',
		}
		auto_scaling_group_numeric_parameter(parent, auto_scaling_group, :cooldown, options)
	end
	
	def show_hide_auto_scaling_group_instances_link(auto_scaling_group)
		if auto_scaling_group.instances.size > 0
			r = content_tag(:span, expand_instances_image_link(auto_scaling_group), :id => "auto_scaling_group_#{auto_scaling_group.id}_expand_instances")
			r += content_tag(:span, hide_instances_image_link(auto_scaling_group), :id => "auto_scaling_group_#{auto_scaling_group.id}_compress_instances", :style => "display:none;")
			return r
		else
			options ={}
			options[:class] = 'control-icon-disabled'
			options[:title] = 'List Instances [none available]'
			options[:alt] = options[:title]
			image_tag 'computer.png', options
		end
	end

	def show_hide_auto_scaling_group_triggers_link(auto_scaling_group)
		r = content_tag(:span, expand_triggers_image_link(auto_scaling_group), :id => "auto_scaling_group_#{auto_scaling_group.id}_expand_triggers")
		r += content_tag(:span, hide_triggers_image_link(auto_scaling_group), :id => "auto_scaling_group_#{auto_scaling_group.id}_compress_triggers", :style => "display:none;")
		return r
	end
end
