module RailsAdminSettings
  def self.kinds
    ret = [
      'string',
      'text',
      'integer',
      'boolean',
      'html',
      'code',
      'sanitized',
      'yaml',
      'phone',
      'phones',
      'email',
      'address',
      'file',
      'image',
      'url',
      'domain',
      'color',

      'js',
      'css',
    ]
    if RailsAdminSettings.mongoid? or true
      ret += [
      'array',
      'hash',

      'enum',
      'multiple_enum',
      'custom_enum',
      'multiple_custom_enum'
      ]
    end
    ret.freeze
  end

  def self.types
    self.kinds
  end
end
