module RailsAdminSettings
  def self.kinds
    [
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
      'css'
    ].freeze
  end

  def self.types
    self.kinds
  end
end
