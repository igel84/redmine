require "xmpp4r"

class JabberRobot
  
  @@robot = nil
  
  def self.robot
    unless @@robot
      ::Jabber::debug = RedmineAddons::Config.settings['jabber']['debug'] || false
      
      @@robot = ::Jabber::Client::new(Jabber::JID::new( RedmineAddons::Config.settings['jabber']['login'] ))
      @@robot.connect
      @@robot.auth RedmineAddons::Config.settings['jabber']['password']
    end
    @@robot
  end
  
  def notify(recepient, text)  
    message = create_message recepient, text 
    self.class.robot.send message    
  end
  
  
  private
  
  def create_message(recepient, text)
    message = ::Jabber::Message::new recepient, text
    message.set_type :chat

    # Create the html part
    # h = REXML::Element::new("html")
    # h.add_namespace('http://jabber.org/protocol/xhtml-im')
    # 
    # # The body part with the correct namespace
    # b = REXML::Element::new("body")
    # b.add_namespace('http://www.w3.org/1999/xhtml')
    # 
    # # The html itself
    # t = REXML::Text.new(text, false, nil, true, nil, %r/.^/ )
    # 
    # # Add the html text to the body, and the body to the html element
    # b.add(t)
    # h.add(b)
    # 
    # # Add the html element to the message
    # message.add_element(h)
    
    message
  end
  
end