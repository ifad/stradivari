module Tabs
  module Helpers

    module Generator
      def tabs_for(*pass, &block)
        options = pass.extract_options!
        Tabs::Generator.new(self, options).tap {|tabs| tabs.instance_exec(*pass, &block) }.to_s
      end
    end

  end
end
