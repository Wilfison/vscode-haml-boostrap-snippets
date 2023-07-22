module Helpers
  REGEX_PLACEHOLDER = /bssnippet-\d{1,2}-(?:default-)?\w*/
  REGEX_NAMED_PLACEHOLDER = /bssnippet-(?<index>\d{1,2})-(?<type>\w*)-?(?<value>\w*)/

  VARIANTS = 'primary,secondary,success,danger,warning,info,light,dark'.freeze
  SIZES = 'lg,md,sm,xs'.freeze
  COLUMNS = '1,2,3,4,5,6,7,8,9,10,11,12'.freeze

  DISRECTIONS = 'center,end,start'.freeze

  DROP_DISRECTIONS_V4 = 'down,up,left,right'.freeze
  DROP_DIRECTIONS_V5 = 'down-center,up,up-center,end,start'.freeze

  def self.build_placeholder_options(placeholder, options)
    "${#{placeholder['index']}|#{options}|}"
  end

  def self.build_placeholder_default(placeholder)
    "${#{placeholder['index']}:#{placeholder['value'].gsub('_', '-')}}"
  end

  def self.build_placeholder_content(file_location, placeholder)
    case placeholder['type']
    when 'variants'
      build_placeholder_options(placeholder, VARIANTS)
    when 'sizes'
      build_placeholder_options(placeholder, SIZES)
    when 'columns'
      build_placeholder_options(placeholder, COLUMNS)
    when 'directions'
      build_placeholder_options(placeholder, DISRECTIONS)
    when 'drop_directions_v4'
      build_placeholder_options(placeholder, DROP_DISRECTIONS_V4)
    when 'drop_directions_v5'
      build_placeholder_options(placeholder, DROP_DIRECTIONS_V5)
    when 'default'
      build_placeholder_default(placeholder)
    else
      raise "Unknown placeholder type: '#{placeholder['type']}' in file: '#{file_location}'"
    end
  end

  def self.find_placeholder_declaration(file_content)
    # get string matches
    placeholders_matches = file_content.scan(REGEX_PLACEHOLDER)
    placeholders = []

    placeholders_matches.each do |placeholder|
      groups = placeholder.match(REGEX_NAMED_PLACEHOLDER)

      placeholders << { 'name' => placeholder.to_s }.merge(groups.named_captures)
    end

    placeholders
  end

  def self.replace_placeholders(file_location)
    file_content = File.read(file_location)
    placeholders = find_placeholder_declaration(file_content)

    placeholders.each do |placeholder|
      placeholder_content = build_placeholder_content(file_location, placeholder)

      file_content.gsub!(placeholder['name'], placeholder_content)
    end

    file_content
  end

  def self.build_snippet(bs_version, file_location)
    file_content = replace_placeholders(file_location)

    file_name = File.basename(file_location, '.haml')

    html5 = file_name == 'html5'
    name = html5 ? 'HTML5 Bootstrap' : file_name.gsub('-', ' ').capitalize
    prefix = html5 ? '!bs' : 'bs'

    [
      name,
      {
        prefix: "#{prefix}#{bs_version}-#{file_name}",
        body: file_content.split("\n")
      }
    ]
  end
end
