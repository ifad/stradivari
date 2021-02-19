# frozen_string_literal: true

module Stradivari
  module Concerns
    module CssFriendly
      extend ActiveSupport::Concern

      def css_friendly(dom_id)
        dom_id.gsub(/[\[\]:.,]/, '_')
      end
    end
  end
end
