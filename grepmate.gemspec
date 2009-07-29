# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{grepmate}
  s.version = "2.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Steven Soroka", "Zach Holt"]
  s.date = %q{2009-07-29}
  s.default_executable = %q{grepmate}
  s.description = %q{Extremely fast search of rails projects or rails source for code, open in textmate or browser with html output}
  s.email = %q{ssoroka78@gmail.com}
  s.executables = ["grepmate"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/grepmate",
     "config/dot-grepmate",
     "grepmate.gemspec",
     "lib/.empty",
     "lib/.git-empty",
     "lib/grepmate.rb",
     "lib/output/file_and_line.rb",
     "lib/output/html.rb",
     "lib/output/text.rb",
     "lib/output/textmate.rb",
     "spec/grepmate_spec.rb",
     "spec/spec_helper.rb",
     "tmp/grepmate.html"
  ]
  s.homepage = %q{http://github.com/ssoroka/grepmate}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Extremely fast search of rails projects or rails source for code, open in textmate or browser with html output}
  s.test_files = [
    "spec/grepmate_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<main>, [">= 2.8.3"])
      s.add_runtime_dependency(%q<syntax>, [">= 1.0.0"])
    else
      s.add_dependency(%q<main>, [">= 2.8.3"])
      s.add_dependency(%q<syntax>, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<main>, [">= 2.8.3"])
    s.add_dependency(%q<syntax>, [">= 1.0.0"])
  end
end
