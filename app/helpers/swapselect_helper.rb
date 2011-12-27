# copy this file to your project!!!
module SwapselectHelper
	def swapselect(object_name, object, method, choices, params={})
		javascript_tag swapselect_html(object_name, object, method, choices, params)
	end

  def swapselect_html(object_name, object, method, choices, params)
 		param_name = "#{method.to_s.singularize}_ids"
    # make the size between 5 and 10 depending on the size of the choices
    size = params[:size] || [8, choices.size].min
    size = [size, 5].max
    id = params[:id]
		selected = object.send param_name

		buff = "new SwapSelect('#{object_name.to_s}[#{param_name}][]', new Array("

		choices.each do |elem|
			is_selected = selected.any? { |item| item == elem.last }
			buff += "new Array( '#{elem.last}', '#{elem.first}', #{is_selected} ),"
		end

		buff.slice!( buff.length - 1 )
		buff += "), #{size}"
    buff += ", '#{id}'" unless id.blank?
    buff += " );"

		return buff
  end
	
end
