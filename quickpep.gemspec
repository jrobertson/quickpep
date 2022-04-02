Gem::Specification.new do |s|
  s.name = 'quickpep'
  s.version = '0.1.1'
  s.summary = 'Quick Personal Expenses Planner - for people too lazy to use a spreadsheet or finance app.'
  s.authors = ['James Robertson']
  s.files = Dir["lib/quickpep.rb"]
  s.add_runtime_dependency('event_nlp', '~> 0.6', '>=0.6.4')
  s.add_runtime_dependency('dynarex', '~> 1.9', '>=1.9.8')
  s.signing_key = '../privatekeys/quickpep.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'digital.robertson@gmail.com'
  s.homepage = 'https://github.com/jrobertson/quickpep'
end
