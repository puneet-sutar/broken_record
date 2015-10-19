module BrokenRecord
  class ResultAggregator
    def initialize
      @total_errors = 0
      @aggregated_results = {}
      BrokenRecord::BrokenRecordReport.truncate!
    end

    def add_result(result)
      @aggregated_results[result.job.klass] ||= []
      @aggregated_results[result.job.klass] << result

      if klass_done?(result.job.klass)
        report_results result.job.klass
      end
    end

    def report_final_results
      if @total_errors == 0
        puts "\nAll models validated successfully.".green
      else
        puts "\n#{@total_errors} errors were found while running validations.".red
      end
    end

    private

    def klass_done?(klass)
      @aggregated_results[klass].count == Job.jobs_per_class
    end

    def report_results(klass)
      @total_errors += @aggregated_results[klass].map(&:errors).flatten.count
    end

  end
end
