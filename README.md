# Shul: Fetching the value from a textbox

    Shoes.setup do
      gem 'shul'
    end

    require 'shul'

    xml =<<XML
    <app title="Hello World">  
      <textbox id='tb' value='empty' size='40'/>
      <button id="yes1" label="Yes" oncommand="alert(doc.element_by_id('tb').value)"/>
    </app>
    XML

    Shoes.app {Shul.new self, xml}

The above example will display an alert box with the value of the textbox when the button is pressed.

## Running the example

On my Linux box I typed the following:

`/home/james/.shoes/federales/shoes test10.rb`

## Screenshot

![Screenshot of Shul](http://www.jamesrobertson.eu/r/images/2015/may/16/screenshot-of-shul-running-example-10.png)

## Resources

* ?Introducing the Shul gem http://www.jamesrobertson.eu/snippets/2015/feb/28/introducing-the-shul-gem.html?

shul shoes gem
