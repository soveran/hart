Gem::Specification.new do |s|
  s.name              = "hart"
  s.version           = "0.0.1"
  s.summary           = "Hash routing"
  s.description       = "Hash routing"
  s.authors           = ["Michel Martens"]
  s.email             = ["michel@soveran.com"]
  s.homepage          = "https://github.com/soveran/hart"
  s.license           = "MIT"

  s.files = `git ls-files`.split("\n")

  s.add_dependency "seg"
  s.add_development_dependency "cutest"
  s.add_development_dependency "rack-test"
end
