#!/usr/bin/env ruby

require 'json'
require 'pry'

require_relative 'lib/helpers'

BS_VERSIONS = %w[4 5].freeze

BS_VERSIONS.each do |bs_version|
  # List all .haml files in ./bootstrap
  files = Dir.glob("./bootstrap/#{bs_version}/*.haml")

  snippets = {}

  # For each file, replace placeholders
  files.each do |file_location|
    name, snippet = Helpers.build_snippet(bs_version, file_location)

    snippets[name] = snippet
  end

  File.write("./snippets/bootstrap#{bs_version}.code-snippets", JSON.pretty_generate(snippets))
end
