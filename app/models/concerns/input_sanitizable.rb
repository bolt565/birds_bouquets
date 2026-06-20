module InputSanitizable
  extend ActiveSupport::Concern

  included do
    before_validation :sanitize_string_attributes
  end

  private

  def sanitize_string_attributes
    self.class.columns.each do |column|
      next unless [:string, :text].include?(column.type)

      value = read_attribute(column.name)
      next if value.blank?

      sanitized = value
        .delete("\x00")
        .gsub(/[\x01-\x08\x0B\x0C\x0E-\x1F\x7F]/, "")
        .strip

      write_attribute(column.name, sanitized)
    end
  end
end
