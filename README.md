# Shul: Fetching the value from a textbox

    require 'shul'
    require 'green_shoes'

    xml =<<XML
    <app title="Hello World">  
      <textbox id='tb' value='empty' size='40'/>
      <button id="yes1" label="Yes" oncommand="alert(doc.element_by_id('tb').text)"/>
    </app>
    XML

    Shul::Main.new Shoes, xml

The above example will display an alert box with the value of the textbox when the button is pressed.


## Screenshot

![Screenshot of Shul](http://www.jamesrobertson.eu/r/images/2015/may/16/screenshot-of-shul-running-example-10.png)

## Resources

* Introducing the Shul gem http://www.jamesrobertson.eu/snippets/2015/feb/28/introducing-the-shul-gem.html
* shul https://rubygems.org/gems/shul

shul shoes gem
