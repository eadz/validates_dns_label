# http://github.com/eadz/validates_dns_label
# Free to use under the rails licence
# (c) Eaden McKee

module ActiveRecord
  module Validations
    module ClassMethods
      def validates_dns_label(*attr_names)
        options = { :message => ' is an invalid dns label', :on => :save, :allow_nil => false, :allow_blank => false }
        options.update(attr_names.pop) if attr_names.last.is_a?(Hash)
        validates_each(attr_names, options) do |record, attr, value|
          next if value.nil?
          next if value.empty?
          record.errors.add(attr, "contains a wildcard in a non-initial label") if (!value.match(/\*/).nil? && value.match(/^\*/).nil?)
          value.split(".").each do |v|
            record.errors.add(attr, "contains a label longer than 63 characters") if v.length > 63
            record.errors.add(attr, "contains a label begining with a hyphen") if v[0] == 45 # ASCII code for '-'
            record.errors.add(attr, "contains a label ending with a hyphen") if v[-1] == 45 # ASCII code for '-'
            record.errors.add(attr, "contains a label with invalid characters") if v.gsub(/[^0-9a-z\-.*]/, '').length != v.length
            record.errors.add(attr, "mixes a wildcard character with other characters a label") if (v != "*" && !v.match(/\*/).nil?)
          end # end split(".").each
          record.errors.add(attr, "contains a blank label") if value[0] == 46 || !value.match(/\.\./).nil?
        end # end validates_each
      end # end validates_dns label
    end # end ClassMethods
  end # end Validations
end # end ActiveRecord
