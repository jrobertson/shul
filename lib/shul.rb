
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

    doc.root.elements.each {|x| method(x.name.sub(':','_').to_sym).call(x) }

  end

  private
  
  def button(e)

    h = e.attributes
    label = h[:label]
    command = h[:oncommand]    
    
    @shoes.button label do
      eval command if command
    end
    
  end
    
  def hbox(e)

    @shoes.flow do
      e.elements.each {|x|  method(x.name.sub(':','_').to_sym).call(x) }
    end

  end
  
  alias flow hbox

  def html_a(e)
    

    command = e.attributes[:oncommand]

    @shoes.para(
      @shoes.link(e.text).click do
        eval command if command
      end
    )

  end  
  
  def html_p(e)
    @shoes.para e.text
  end

  def image(e)
    h = e.attributes
    @shoes.image h[:src], top: h[:top], left: h[:left]
  end    
  
  def label(e)
    @shoes.para e.attributes[:value]
  end  

  def textbox(e)
    @shoes.edit_line
  end
  
  def vbox(e)

    @shoes.stack do
      e.elements.each {|x|  method(x.name.sub(':','_').to_sym).call(x) }
    end

  end
  
  alias stack vbox
  
end
