# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{om}
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matt Zumwalt"]
  s.date = %q{2010-12-15}
  s.description = %q{OM (Opinionated Metadata): A library to help you tame sprawling XML schemas like MODS.  Wraps Nokogiri documents in objects with miscellaneous helper methods for doing things like retrieve generated xpath queries or look up properties based on a simplified DSL}
  s.email = %q{matt.zumwalt@yourmediashelf.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc",
    "README.textile"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "History.textile",
    "LICENSE",
    "README.rdoc",
    "README.textile",
    "Rakefile",
    "VERSION",
    "container_spec.rb",
    "lib/om.rb",
    "lib/om/samples.rb",
    "lib/om/samples/mods_article.rb",
    "lib/om/tree_node.rb",
    "lib/om/xml.rb",
    "lib/om/xml/accessors.rb",
    "lib/om/xml/container.rb",
    "lib/om/xml/document.rb",
    "lib/om/xml/generator.rb",
    "lib/om/xml/named_term_proxy.rb",
    "lib/om/xml/node_generator.rb",
    "lib/om/xml/properties.rb",
    "lib/om/xml/property_value_operators.rb",
    "lib/om/xml/term.rb",
    "lib/om/xml/term_value_operators.rb",
    "lib/om/xml/term_xpath_generator.rb",
    "lib/om/xml/terminology.rb",
    "lib/om/xml/validation.rb",
    "lib/om/xml/vocabulary.rb",
    "om.gemspec",
    "spec/fixtures/CBF_MODS/ARS0025_016.xml",
    "spec/fixtures/RUBRIC_mods_article_template.xml",
    "spec/fixtures/mods-3-2.xsd",
    "spec/fixtures/mods_articles/hydrangea_article1.xml",
    "spec/fixtures/test_dummy_mods.xml",
    "spec/integration/rights_metadata_integration_example_spec.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb",
    "spec/unit/accessors_spec.rb",
    "spec/unit/container_spec.rb",
    "spec/unit/document_spec.rb",
    "spec/unit/generator_spec.rb",
    "spec/unit/named_term_proxy_spec.rb",
    "spec/unit/node_generator_spec.rb",
    "spec/unit/om_spec.rb",
    "spec/unit/properties_spec.rb",
    "spec/unit/property_value_operators_spec.rb",
    "spec/unit/term_builder_spec.rb",
    "spec/unit/term_spec.rb",
    "spec/unit/term_value_operators_spec.rb",
    "spec/unit/term_xpath_generator_spec.rb",
    "spec/unit/terminology_builder_spec.rb",
    "spec/unit/terminology_spec.rb",
    "spec/unit/validation_spec.rb",
    "spec/unit/xml_spec.rb"
  ]
  s.homepage = %q{http://github.com/mediashelf/om}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{OM (Opinionated Metadata): A library to help you tame sprawling XML schemas like MODS.}
  s.test_files = [
    "spec/integration/rights_metadata_integration_example_spec.rb",
    "spec/spec_helper.rb",
    "spec/unit/accessors_spec.rb",
    "spec/unit/container_spec.rb",
    "spec/unit/document_spec.rb",
    "spec/unit/generator_spec.rb",
    "spec/unit/named_term_proxy_spec.rb",
    "spec/unit/node_generator_spec.rb",
    "spec/unit/om_spec.rb",
    "spec/unit/properties_spec.rb",
    "spec/unit/property_value_operators_spec.rb",
    "spec/unit/term_builder_spec.rb",
    "spec/unit/term_spec.rb",
    "spec/unit/term_value_operators_spec.rb",
    "spec/unit/term_xpath_generator_spec.rb",
    "spec/unit/terminology_builder_spec.rb",
    "spec/unit/terminology_spec.rb",
    "spec/unit/validation_spec.rb",
    "spec/unit/xml_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
      s.add_runtime_dependency(%q<facets>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["< 2.0.0"])
      s.add_development_dependency(%q<mocha>, [">= 0.9.8"])
      s.add_development_dependency(%q<ruby-debug>, [">= 0"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.4.2"])
      s.add_runtime_dependency(%q<facets>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<mocha>, [">= 0.9.8"])
      s.add_development_dependency(%q<ruby-debug>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<facets>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<rspec>, ["< 2.0.0"])
      s.add_dependency(%q<mocha>, [">= 0.9.8"])
      s.add_dependency(%q<ruby-debug>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 1.4.2"])
      s.add_dependency(%q<facets>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<mocha>, [">= 0.9.8"])
      s.add_dependency(%q<ruby-debug>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<facets>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<rspec>, ["< 2.0.0"])
    s.add_dependency(%q<mocha>, [">= 0.9.8"])
    s.add_dependency(%q<ruby-debug>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 1.4.2"])
    s.add_dependency(%q<facets>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<mocha>, [">= 0.9.8"])
    s.add_dependency(%q<ruby-debug>, [">= 0"])
  end
end

