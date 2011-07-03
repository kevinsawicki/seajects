spec = Gem::Specification.new do |s|
  s.name = 'seajects'
  s.version = '0.1.0'
  s.summary = "Generate object models from ctags"
  s.description = %{Generate hashes or JSON from ctags output}
  s.files = Dir['lib/**/*.rb'] + Dir['test/**/*.rb']
  s.require_path = 'lib'
  s.autorequire = 'seajects'
  s.author = "Kevin Sawicki"
  s.email = "kevinsawicki@gmail.com"
  s.homepage = "https://github.com/kevinsawicki/seajects"
end