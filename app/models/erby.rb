require 'erb'
module Erby
  include ActionView::Helpers::UrlHelper
  def template path, which
    tpl = File.read( File.join(path, const_get(which.to_s.upcase + '_TEMPLATE') ) )
    ERB.new(tpl, 0, '-')
  end
end
