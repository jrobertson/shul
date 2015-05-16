Gem::Specification.new do |s|
  s.name = 'shul'
  s.version = '0.2.0'
  s.summary = 'Shoes + XUL = SHUL'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb']
  s.add_runtime_dependency('rexle', '~> 1.3', '>=1.3.5') 
  s.add_runtime_dependency('rxfhelper', '~> 0.2', '>=0.2.3') 
  s.signing_key = '../privatekeys/shul.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/shul'
end
