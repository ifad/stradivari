module Stradivari
  module Table

    class Builder < Stradivari::Builder

      Implementations = {
        action:    'ActionBuilder',
        boolean:   'BooleanBuilder',
        checkbox:  'CheckboxBuilder',
        text:      'TextBuilder',
        number:    'NumberBuilder',
        date:      'DateBuilder',
        text_link: 'TextLinkBuilder'
      }

      Implementations.each do |id, name|
        require "stradivari/table/builder/#{id}_builder"
        Implementations[id] = const_get(name)
      end.freeze

    end

  end
end
