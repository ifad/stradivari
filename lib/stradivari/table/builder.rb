# frozen_string_literal: true

module Stradivari
  module Table
    class Builder < Stradivari::Builder
      IMPLEMENTATIONS = {
        action: 'ActionBuilder',
        boolean: 'BooleanBuilder',
        checkbox: 'CheckboxBuilder',
        text: 'TextBuilder',
        number: 'NumberBuilder',
        date: 'DateBuilder',
        text_link: 'TextLinkBuilder'
      }

      IMPLEMENTATIONS.each do |id, name|
        require "stradivari/table/builder/#{id}_builder"
        IMPLEMENTATIONS[id] = const_get(name)
      end.freeze
    end
  end
end
