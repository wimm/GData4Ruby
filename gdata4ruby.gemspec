version = File.read(File.expand_path("../VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.name = 'gdata4ruby'
  s.version = version
  s.summary = "A full featured wrapper for interacting with the base Google Data API"
  s.description = "A full featured wrapper for interacting with the base Google Data API, including authentication and basic object handling"

  s.author = "Mike Reich"
  s.email = "mike@seabourneconsulting.com"
  s.homepage = "http://cookingandcoding.com/gdata4ruby/"

  s.files = [
    "README.md",
    "CHANGELOG",
    "lib/gdata4ruby.rb",
    "lib/gdata4ruby/base.rb",
    "lib/gdata4ruby/service.rb",
    "lib/gdata4ruby/request.rb",
    "lib/gdata4ruby/gdata_object.rb",
    "lib/gdata4ruby/utils/utils.rb",
    "lib/gdata4ruby/acl/access_rule.rb"
  ]
  s.rubyforge_project = 'gdata4ruby'
  s.has_rdoc = true
  s.test_files = [
    'test/unit.rb'
  ] 
end 
