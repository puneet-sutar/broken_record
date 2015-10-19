module BrokenRecord
  class JobResult
    attr_reader :start_time, :end_time, :errors, :job

    def initialize(job)
      @job = job
      @errors = []
    end

    def start_timer
      @start_time = Time.now
    end

    def stop_timer
      @end_time = Time.now
    end

    def add_error(error)
      @errors << output_error(error).id
    end

    def output_error(error)
      report = BrokenRecord::BrokenRecordReport.new(record_type: error[:klass].to_s)
      if error[:record]
        report.record_id = error[:record]['id']
      end
      report.validation_errors = compute_validation_error(error[:record], error[:exception], error[:errors])
      report.save!
      report
    end

    def compute_validation_error(record, exception, errors)
      compact_output = BrokenRecord::Config.compact_output
      if exception
        backtrace = exception.backtrace.join("\n")
        if record
          if compact_output
            "Exception while processing the record. #{exception.message}"
          else
            "Exception while processing the record. #{exception.message}\n#{backtrace}"
          end
        else
          if compact_output
            "Exception while loading model. #{exception.message}"
          else
            "Exception while loading model. #{exception.message}\n#{backtrace}"
          end
        end
      else
        if compact_output
          "Invalid record"
        else
          errors.map{ |attr, msg| "#{attr} - #{msg}"}.join("\n")
        end
      end
    end
  end
end
