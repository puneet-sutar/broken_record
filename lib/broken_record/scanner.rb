require 'broken_record/job'
require 'broken_record/result_aggregator'
require 'broken_record/broken_record_report'
require 'parallel'

module BrokenRecord
  class Scanner
    def run(class_names)
      BrokenRecord::Config.aggregator_class.constantize.new.tap do |aggregator|
        classes = classes_to_validate(class_names)

        BrokenRecord::Config.before_scan_callbacks.each { |callback| callback.call }

        jobs = BrokenRecord::Job.build_jobs(classes)

        callback = proc do |_, _, result|
          aggregator.add_result result if result.is_a? BrokenRecord::JobResult
        end

        Parallel.each(jobs, :finish => callback) do |job|
          ActiveRecord::Base.connection.reconnect!
          BrokenRecord::Config.after_fork_callbacks.each { |callback| callback.call }
          job.perform
        end
      end
    end

    private

    def classes_to_validate(class_names)
      if class_names.empty?
        load_all_active_record_classes
      else
        class_names.map(&:strip).map(&:constantize)
      end
    end

    def load_all_active_record_classes
      Rails.application.eager_load!
      objects = Set.new
      # Classes to skip may either be constants or strings.  Convert all to strings for easier lookup
      classes_to_skip = BrokenRecord::Config.classes_to_skip.map(&:to_s)
      ActiveRecord::Base.descendants.each do |klass|
        # Use base_class so we don't try to validate abstract classes and so we don't validate
        # STI classes multiple times.  See active_record/inheritance.rb for more details.
        objects.add klass.base_class unless classes_to_skip.include?(klass.to_s)
      end

      objects.sort_by(&:name)
    end
  end
end
