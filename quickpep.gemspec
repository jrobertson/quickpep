Gem::Specification.new do |s|
  s.name = 'quickpep'
  s.version = '0.3.0'
  s.summary = 'Quick Personal Expenses Planner - for people too ' + 
      'lazy to use a spreadsheet or finance app.'
  s.authors = ['James Robertson']
  s.files = Dir["lib/quickpep.rb", 'data/quickpep.txt']
  s.add_runtime_dependency('event_nlp', '~> 0.8', '>=0.8.1')
  s.add_runtime_dependency('dynarex', '~> 1.10', '>=1.10.0')
  s.add_runtime_dependency('weblet', '~> 0.4', '>=0.4.1')
  s.signing_key = '../privatekeys/quickpep.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'digital.robertson@gmail.com'
  s.homepage = 'https://github.com/jrobertson/quickpep'
end
