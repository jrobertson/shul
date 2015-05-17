
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
#  http://www.xul.fr/tutorial/
#------------------------------------------------------------------

require 'rexle'
require 'rxfhelper'


class Shul

  def initialize(shoes, source)
    
    @shoes = shoes
    
    @doc = if source.is_a? Rexle then source
    else
      xml, _ = RXFHelper.read(source)
      Rexle.new(xml)
    end

    @doc.root.elements.each {|x| method(x.name.sub(':','_').to_sym).call(x) }

    def @doc.element_by_id(id)
      self.root.element("//*[@id='#{id}']")
    end

  end
    
  private
  
  def button(e)

    buttonx e
    
  end
  
  def buttonx(e, label = :label, oncommand = :oncommand)

    h = e.attributes
    label = h[label]
    command = h[oncommand]    
    
    @shoes.button label do
      eval command if command
    end
    
  end  
  
  def checkbox(e)
    
    h = e.attributes
        
    c = @shoes.check
    c.checked = h[:checked] == 'true'
    @shoes.inscription h[:label]
    
  end  

  def description(e)
    @shoes.para e.attributes[:value]
  end
  
  def doc()
    @doc
  end
  
  def editbox(e, name = :edit_line)
    
    def e.value()   self.attributes[:value]        end
    def e.value=(v) self.attributes[:value] = v    end        
    
    obj = @shoes.method(name).call
    obj.text = e.attributes[:value]
    obj.change {|x|   e.value = x.text() }
    
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
  
  def html_em(e)
    @shoes.para(@shoes.em(e.text))
  end
  
  alias html_i html_em

  def html_input(e)
    
    case e.attributes[:type]
    when 'text'
      editbox e
    when 'button'
      buttonx e, :value, :onclick
    end
  end  
  
  def html_p(e)
    @shoes.para e.text
    e.elements.each {|x|  method(x.name.sub(':','_').to_sym).call(x) }
  end
  
  def html_span(e)
    @shoes.span e.text
  end
  
  def html_strong(e)
    @shoes.strong e.text
  end
  
  alias html_b html_strong

  def image(e)
    h = e.attributes
    @shoes.image h[:src], top: h[:top], left: h[:left]
  end    
  
  def label(e)
    @shoes.para e.attributes[:value]
  end
  
  def listbox(e)
    a = e.xpath 'listem/attribute::label'
    @shoes.list_box items: a
  end  

  def progressmeter(e)
    @shoes.progress
  end  
  
  def radiogroup(e)

    
    e.xpath('radio').each do |x|
      
      def x.value()   self.attributes[:value]        end
      def x.value=(v) self.attributes[:value] = v    end       
        
      x.value = x.attributes[:value]
      h = x.attributes
      
      r = @shoes.radio
        
      r.checked = h[:checked] == 'true'
      @shoes.inscription h[:label]
      
    end
    
  end
  
  def script(e)
    eval e.text.unescape
  end

  def textbox(e)
    
    name = if e.attributes[:multiline] and e.attributes[:multiline] == 'true' then
      :edit_box
    else
      :edit_line
    end
    
    editbox e, name
    
  end
  
  def vbox(e)

    @shoes.stack do
      e.elements.each {|x|  method(x.name.sub(':','_').to_sym).call(x) }
    end

  end
  
  alias stack vbox
  
end