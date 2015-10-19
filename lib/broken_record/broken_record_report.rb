require 'active_record'

module BrokenRecord
  class BrokenRecordReport < ActiveRecord::Base
    self.table_name = "broken_record_reports"
    serialize :record_data, Hash

    def self.truncate!
      connection.execute("TRUNCATE TABLE #{self.table_name}")
    end

  end
end
