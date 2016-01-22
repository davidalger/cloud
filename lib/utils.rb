##
 # Copyright © 2015 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

def include_conf (file, conf)
  proc = Proc.new {}
  eval(File.read(file), proc.binding, file)
end

def generate_exports (env = {})
  exports = ''
  env.each do |key, val|
    exports = %-#{exports}\nexport #{key.upcase}="#{val}";-
  end
  return exports
end
