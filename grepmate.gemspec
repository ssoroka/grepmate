Gem::Specification.new do |s|
  s.name = %q{grepmate}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Steven Soroka"]
  s.date = %q{2008-12-05}
  s.default_executable = %q{grepmate}
  s.description = %q{Extremely fast search of rails projects or rails source for code, open in textmate or browser with html output}
  s.email = %q{ssoroka78@gmail.com}
  s.executables = ["grepmate"]
  s.extra_rdoc_files = ["bin/grepmate", "README"]
  s.files = ["bin/grepmate", "Rakefile", "README", "Manifest", "grepmate.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/ssoroka/grepmate}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Grepmate", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{grepmate}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Extremely fast search of rails projects or rails source for code, open in textmate or browser with html output}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_development_dependency(%q<main>, [">= 0"])
    else
      s.add_dependency(%q<main>, [">= 0"])
    end
  else
    s.add_dependency(%q<main>, [">= 0"])
  end
end
