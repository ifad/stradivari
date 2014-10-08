module StradiTest
  module FileHelpers
    def load_result(name)
      @result = ''
      File.new(File.dirname(__FILE__) + "/../expected_results/#{name}").each_line { |l| @result += l }
      @result
    end

    def save_result(name, result)
      File.open(File.dirname(__FILE__) + "/../actual_results/#{name}", 'w') { |file| file.write(result) }
    end
  end
end