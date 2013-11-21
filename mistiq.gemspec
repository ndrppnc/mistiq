# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mistiq/version"

Gem::Specification.new do |s|
  s.name               = "mistiq"
  s.version            = Mistiq::VERSION
  s.default_executable = "mistiq"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrei Papancea"]
  s.date = %q{2013-11-21}
  s.description = %q{Dynamically restrict access to your Rails application}
  s.email = %q{alp2200@columbia.edu}
  s.homepage = 'https://rubygems.org/gems/mistiq'
  s.license = %q{OSL-3.0}
  s.files = ["Rakefile", "lib/mistiq.rb", "lib/mistiq/base.rb", "lib/mistiq/middleware.rb", "lib/mistiq/init.rb", "lib/mistiq/defaults.rb", "bin/mistiq"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{2.1.5}
  s.summary = %q{Dynamically restrict access to your Rails application and while automatically adjusting the view of your application.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end