Gem::Specification.new do |s|
  s.name        = 'stapel'
  s.version     = '0.0.1'
  s.date        = '2016-08-03'
  s.summary     = "Batch processing made easy"
  s.description = "A tool for dead simple batch processing on multiple machines"
  s.authors     = ["Cornelius Aschermann"]
  s.email       = 'coco@hexgolems.com'
  s.files       = Dir.glob("lib/*.rb")
  s.homepage    = 'http://github.com/eqv/stapel'
  s.license       = 'MIT'
  s.executables << "stapel"
  s.add_runtime_dependency 'net-scp', '~> 1.1', '>= 1.2.1'
  s.add_runtime_dependency 'net-ssh', '~> 3.2'
end
