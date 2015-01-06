# file: shul.rb
# author: James Robertson
# license: MIT
# summary: Shoes + XUL = SHUL

# -----------------------------------------------------------------
#
# This code is designed to be executed from a Shoes app
# e.g.
#
=begin

xml =<<XML
<app>
  <button id="yes1" label="Yes" oncommand="alert 'hello world'"/>
</app>
XML

Shoes.app {Shul.new self, xml}

=end

# resources:
#  https://en.wikipedia.org/wiki/Shoes_%28GUI_toolkit%29
#  https://developer.mozilla.org/en-US/docs/Mozilla/Tech/XUL
# 
#------------------------------------------------------------------

require 'rexle'
require 'rxfhelper'


class Shul

  def initialize(shoes, source)
    
    @shoes = shoes
    xml, _ = RXFHelper.read(source)
    doc = Rexle.new(xml)

    doc.root.traverse do |x|
      method(x.name.to_sym).call(x.attributes)
    end
  end

  def button(h)
    
    label = h[:label]
    command = h[:oncommand]    
    
    @shoes.button 'label' do
      eval command if command
    end
    
  end

end
