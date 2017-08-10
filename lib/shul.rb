
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
require 'shul'
require 'green_shoes'

xml =<<XML
<app title="Hello World" width='500' height='200'>
  <button id="yes1" label="Yes" oncommand="alert 'hello world'"/>
</app>
XML

doc = Shul::Shule.new xml
Shul::Main.new Shoes, doc

=end

# resources:
#   xul:
#     https://en.wikipedia.org/wiki/Shoes_%28GUI_toolkit%29
#     https://developer.mozilla.org/en-US/docs/Mozilla/Tech/XUL
#     http://www.xul.fr/tutorial/
#     https://developer.mozilla.org/en-US/docs/Mozilla/Tech/XUL/Tutorial/The_Box_Model
#   shoes:
#     http://shoesrb.com/manual/Element.html
#     http://shoesrb.com/manual/App.html
#     http://shoesrb.com/manual/Slots.html (floww or stacks)
#     http://shoesrb.com/manual/Events.html
#------------------------------------------------------------------



# modifications
#
# 11-Aug-2017:  feature: An element can now be removed using method *remove*.
# 10-Aug-2017:  feature: A Textbox element can now be created dynamically
#                e.g. txt = e.create_element('textbox'); e.append_child txt
# 09-Aug-2017:  feature: onkeypress() now implemented. 
#               Listboxes can now be rendered. Radiogroup events now functional
#               Textbox implementation is now functional.
# 09-jun-2017:  bug fix: The button class has now been implemented with Shule
# 22-May-2017:  feature: The font size for a label can now be set
# 21-May-2017:  Added a Document Object Model (DOM) class called Shule
# 23-Jan-2017:  A Vbox or Hbox width can now be set
# 13-Jan-2017:  The script tag is now executed only after the 
#               document elements have been loaded
# 10-Jan-2017:  Implemented methods value() and value=() for the label element
# 06-Dec-2016:  bug fix: Removes the file /tmp/__green_shoes_temporary_file__
#               to prevent a file lock on a thin client server setup
# 26-Nov-2016:  A background color can be applied to an hbox using the 
#               attribute *bgcolor*. The color of a label be changed using 
#               the attribute *color*.
# 10-May-2016:  The background color of a vbox can now be changed
#               An hbox or vbox can now have a margin
#               A label can now have a width. Helpful when using it within  
#               an hbox element
# 29-Mar-2016:  Code improvement: Uses refinements for the the 
#                         Rexle::Element enhancement rather than a monkey patch
#               * tested  using the green_shoes gem.


require 'domle'


module RexleObject 
  refine Rexle::Element do
    
    @obj = nil
    @obj_children = []

    def obj()      @obj        end
    def obj=(obj)  @obj = obj  end
    def obj_children()      @obj_children        end
    def obj_children=(obj)  @obj_children = obj  end        

  end
end

DEFAULT_SHUL_CSS = <<CSS

app {background-color: white}
hbox {background-color: yellow}
vbox {background-color: #0e0}
label {background-color: #aa1}
listbox {background-color: #aa1}
listitem {background-color: #aa1}
radiogroup {background-color: #abc}
radio {background-color: #884 }

CSS

module Shul
  

  class Shule < Domle
    
    attr_accessor :callback

    class Box < Element
      attr2_accessor *%i(background-color id margin padding)

      def append_child(obj)

        node = self.add obj
        @rexle.callback.add_element(node, obj) if @rexle.callback
      end
      
      def deep_clone() 

        Shule.new(self.xml, rexle: @rexle).root

      end      
      
      def remove()
        @rexle.callback.remove_element(self) if @rexle.callback
        self.delete   
      end
      
    end  

    class Component < Box
      attr2_accessor *%i(width height)
      
    end  
    
    class App < Component

    end
    
    class Button < Component

    end    

    class Hbox < Box
    end

    class Vbox < Box
    end

    class Label < Component

    end
    
    class Listbox < Component

    end

    class Listitem < Component

    end        

    class Radiogroup < Component

    end   
    
    class Radio < Component

    end       
    
    class Textbox < Component      

      attr2_accessor *%i(value size)
      
      def initialize(name='textbox', attributes: nil, rexle: nil)

        h = {value: '', size: '40'}
        h.merge!(attributes) if attributes
        super(name, attributes: h, rexle: rexle)
      end
    end           
    
    
    def create_element(type, id: '')
      
      h = {
        textbox: Shul::Shule::Textbox
      }

      h[type.to_sym].new(attributes: {id: id}, rexle: self)
    end    
    
    def inspect()    
      "#<Shule:%s>" % [self.object_id]
    end  
    
    
    protected
      
    def add_default_css()
      add_css DEFAULT_SHUL_CSS
    end  

    private
    
    def defined_elements()
      super.merge({
        app: Shule::App,
        button: Shule::Button,
        script: Shule::Script,
        hbox: Shule::Hbox,
        vbox: Shule::Vbox,
        label: Shule::Label,
        listbox: Shule::Listbox,
        listitem: Shule::Listitem,
        radiogroup: Shule::Radiogroup,
        radio: Shule::Radio,
        textbox: Shule::Textbox
      })
    end

  end

  

  class Main
        
    
    def initialize(shoes, source)      

      if source.is_a? Shule then 
        
        doc = source
        
      else
        
        xml, type = RXFHelper.read(source)
        # is the first line an XML processing instruction?

        begin
          doc = Shule.new(xml)
        rescue
          puts 'Shule: something went wrong'
          puts '->' + ($!).inspect
        end
        
      end          
      
      attr = {width: 300, height: 200}.merge doc.root.attributes.to_h      
      
      bflag = if attr.has_key? :width and attr.has_key? :height then
        
        attr[:width] = attr[:width].to_i
        attr[:height] = attr[:height].to_i
        
        false         
      else
        true
      end
      
      shoes.app(attr) do  

        def reload()
          puts 'not yet implemented'
        end
        
        #button 'test' do
        #  alert('fun')
        #end
        
        
        shul = Shul::App.new self, doc, refresh: bflag, \
                                          attributes: {title: 'Shul'}
        Thread.new do
          
          # The following file is generated by Shoes and needs to be 
          # removed to avoid file locks in a thin client server setup.
          
          if File.exists? '/tmp/__green_shoes_temporary_file__' then
            FileUtils.rm '/tmp/__green_shoes_temporary_file__'
          end
          
        end
          
      end
      
    end
    
  end
    
    
  class App
    
    def initialize(shoes_app, doc, refresh: false, attributes: {})
                        
      # To find out the window dimensions we must first render the app
      shul = Window.new(shoes_app, doc)            

      if refresh then
        
        h = attributes
        
        shoes_app.start do |app|

          sleep 0.0001
          
          box = doc.root.element('hbox | vbox')          

          ht, wh = find_max_dimensions(box)
          
          h[:width],h[:height] = ht, wh
          
          win = window(h) {  Window.new self, doc }

          app.close # closes the initial shoes app        
          shul = nil

        end        
      end
      
      doc.callback = shul
      
    end

    def reload()
      #alert 'hello world'
      '@shoes.inspect'
    end
    
    private
    
    def find_max_dimensions(e)
      
      a = e.elements.map(&:obj)

      maxwidth = a.max_by{|x| x.width}.width      
      maxheight = a.inject(0) {|r,x2| r += x2.height }
      
      [maxwidth, maxheight]

    end    
    
  end

  class Window
    
    using RexleObject
    
    attr_reader :width, :height

    def initialize(shoes, doc)
      
      @shoes = shoes
      @width, @height = 100, 100
      
      @doc = doc
      
      def @doc.element_by_id(id)
        self.root.element("//*[@id='#{id}']")
      end      

      @doc.root.elements.each do |x| 
        method(x.name.sub(':','_').to_sym).call(x) unless x.name == 'script'
      end   
      
      @doc.root.xpath('script').each {|x| script x }
      
      h = @doc.root.attributes
      
      if h[:onkeypress] then
        shoes.keypress do |k| 
          method(h[:onkeypress][/^[a-z]\w+/].to_sym).call(k)
        end
      end

    end
    
    def add_element(node, x)

      node.obj = method(x.name.sub(':','_').to_sym).call(x)
      refresh()

    end
    
    def refresh
      @shoes.flush
    end
    
    def remove_element(node)
      node.obj.clear
      refresh()
    end    
      
    private
    
    def button(e)

      buttonx e
      
    end
    
    def buttonx(e, label = :label, oncommand = :oncommand)

      h = e.attributes
      label = h[label]
      command = h[oncommand]    
      
      e.obj = @shoes.button label do
        eval command if command
      end
      
      def e.label=(v)
        self.obj.style[:text] = v
      end
      
    end  
    
    def checkbox(e)
      
      h = e.attributes
          
      @shoes.flow do
        c = @shoes.check      
        c.checked = h[:checked] == 'true'
        @shoes.para h[:label]
      end
      
    end  

    def description(e)
      e.obj = @shoes.para e.attributes[:value]
    end
    
    def doc()
      @doc
    end
    
    def editbox(e, name = :edit_line)
          
      obj = @shoes.method(name).call
      obj.text = e.attributes[:value]
      obj.change {|x| e.value = x.text() if x.text != e.text}

      
      def e.value()
        self.attributes[:value]
      end
        
      def e.value=(v) 
        self.attributes[:value] = v
        self.obj.text = v
      end    
      
      e.obj =  obj
      
    end

    
    # This method is under-development
    #
    def grid(e)
      
      # get the grid width
      #grid_width = 100
      
      # get the columns
      columns = e.element 'columns'
      cols = columns.xpath 'column'
      cols_flex = cols.map {|x| x.attributes[:flex].to_s.to_i}
      
      # get the rows
      rows = e.element 'rows'
      rows.each do |row|
        a = row.xpath 'row'
        # resize the width of each item
        a.each do |x|
          #x.width = 400
          #puts "x: %s width: %s" + [x.inspect,  x.width]
        end
      end
    end
    
    def hbox(e)
      
      h2 = {}
      h = e.attributes
      
      h2.merge!({margin: h[:margin].to_i})
      h2.merge!({width: h[:width].to_i}) if h[:width]
            
      flow = @shoes.flow  h2 do
        @shoes.background h[:bgcolor] if h[:bgcolor]
        
        if e.text then
          para_style = {}
          
          para_style = {size: e.style[:'font-size'].to_f} if e.style[:'font-size']
          @shoes.para e.text.strip, para_style
        end        
        
        if e.style.has_key? :'background-color' then
          @shoes.background e.style[:'background-color'] 
        end
        
        e.elements.each {|x|  method(x.name.sub(':','_').to_sym).call(x) }
      end
      e.obj = flow

    end
    
    alias flow hbox

    def html_a(e)

      command = e.attributes[:oncommand]

      @shoes.para(
        e.obj = @shoes.link(e.text).click do
          eval command if command
        end
      )

    end  
    
    def html_em(e)
      e.obj = obj =  @shoes.em(e.text)
      @shoes.para()
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
      e.obj = @shoes.para e.text
      e.elements.each {|x|  method(x.name.sub(':','_').to_sym).call(x) }
    end
    
    def html_span(e)
      e.obj = @shoes.span e.text
    end
    
    def html_strong(e)
      e.obj = @shoes.strong e.text
    end
    
    alias html_b html_strong

    def image(e)
      h = e.attributes
      e.obj = @shoes.image h[:src], top: h[:top], left: h[:left]
    end    
    
    # e.g. <label value='light' width='40' color='#45a'/>
    
    def label(e)
      
      h = { }
      h.merge!({width: e.attributes[:width]}) if e.attributes[:width]
      h.merge!({height: e.attributes[:height]}) if e.attributes[:height]
      h.merge!({margin: e.attributes[:margin].to_i}) if e.attributes[:margin]
      h.merge!({stroke: e.attributes[:color]}) if e.attributes[:color]
      h.merge!({size: e.style[:'font-size'].to_f}) if e.style[:'font-size']      
      
      # setting the para bgcolor doesn't work
      #h.merge!({fill: e.attributes[:bgcolor]}) if e.attributes[:bgcolor]
 
      e.obj = @shoes.para e.attributes[:value] || e.text.strip , h           


      
      def e.value()
        self.attributes[:value]
      end
        
      def e.value=(v) 
        self.attributes[:value] = v        
        self.obj.replace v        
      end          
      
    end
    
    def render_elements()
      
      #@shoes.clear
      @doc.root.elements.each do |x| 
        method(x.name.sub(':','_').to_sym).call(x) unless x.name == 'script'
      end      
    end
    
    alias reload render_elements

    def location=(source)
      
      xml, _ = RXFHelper.read(source)
      doc = Rexle.new(xml)
      
      @shoes.close

    end
    
    def listbox(e)

      a = e.xpath('listitem/attribute::label').map(&:to_s)
      e.obj = @shoes.list_box items: a
#       
    end  
    
    def listitem()
    end

    def progressmeter(e)
      e.obj = @shoes.progress
    end  
    
    def radiogroup(e)
      
      r = nil
      
      e.xpath('radio').each do |x|
        
        def x.value()   self.attributes[:value]        end
        def x.value=(v) self.attributes[:value] = v    end       
          
        x.value = x.attributes[:value].to_s
        
        h = x.attributes

        
        @shoes.flow do
          
          r = @shoes.radio :radiogroup01
          r.click { e.value = x.value }

          r.checked = h[:checked] == 'true'
          @shoes.para h[:label]
        end
        
      end      
      
    end
    
    def quit()
      exit
    end
    
    def script(e)
      eval "shoes = @shoes; " + e.text.unescape
    end

    # e.g. <textbox id='tb' value='empty' size='40' multiline='true'/>
    def textbox(e)

      name = if e.attributes[:multiline] \
                        and e.attributes[:multiline] == 'true' then
        :edit_box
      else
        :edit_line
      end
      
      editbox e, name
      
    end
    
    def vbox(e)

      h2 = {}
      h = e.attributes
      
      h2.merge!({margin: h[:margin].to_i}) if h[:margin]
      h2.merge!({width: h[:width].to_i}) if h[:width]

      stack = @shoes.stack h2 do

        if e.text then
          para_style = {}
          
          para_style = {size: e.style[:'font-size'].to_f} if e.style[:'font-size']
          @shoes.para e.text.strip, para_style
        end
        
        @shoes.background h[:bgcolor] if h[:bgcolor]
        
        if e.style.has_key? :'background-color' then
          @shoes.background e.style[:'background-color'] 
        end
        e.elements.each {|x|  method(x.name.sub(':','_').to_sym).call(x) }
        
      end
      
      e.obj = stack      

    end
    
    alias stack vbox
    
  end
end