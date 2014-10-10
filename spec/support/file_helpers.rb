module Stradivari
  module Spec
    module FileHelpers
      def load_result(name)
        Pathname.new(__FILE__).join('../../expected_results', name).read
      end

      def save_result(name, result)
        Pathname.new(__FILE__).join('../../actual_results', name).open('w+') {|file| file.write(result) }
      end
    end
  end
end