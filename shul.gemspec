Gem::Specification.new do |s|
  s.name = 'shul'
  s.version = '0.4.10'
  s.summary = 'Shoes + XUL = SHUL'
  s.authors = ['James Robertson']
  s.files = Dir['lib/shul.rb']
  s.add_runtime_dependency('domle', '~> 0.1', '>=0.1.11') 
  s.signing_key = '../privatekeys/shul.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/shul'
end
