require 'rails/generators'

module BrokenRecord
  class SetupGenerator < Rails::Generators::Base
    def setup_migration
      if Dir.glob("db/migrate/*.rb").select{|file| file.match("_create_broken_record_report")}.blank?
        create_file "db/migrate/#{migration_time}_create_broken_record_report.rb",
                    create_broken_record_report_migration_content
      else
        puts "create_broken_record_report migration already exists"
      end

    end

    private

    def create_broken_record_report_migration_content
      <<EOF
class CreateBrokenRecordReport < ActiveRecord::Migration
  def change
    create_table :broken_record_reports do |t|
      t.string :record_type, null: false
      t.integer :record_id
      t.text :validation_errors
      t.text :record_data
      t.timestamps
    end
  end
end
EOF
    end

    def migration_time
      Time.now.strftime("%Y%m%d%H%M%S")
    end

  end

end
