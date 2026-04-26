module Stradivari
  module Table
    class Builder < Stradivari::Builder
      Implementations = {
        action: 'ActionBuilder',
        boolean: 'BooleanBuilder',
        checkbox: 'CheckboxBuilder',
        text: 'TextBuilder',
        number: 'NumberBuilder',
        date: 'DateBuilder',
        text_link: 'TextLinkBuilder'
      }.each_with_object({}) do |(id, name), memo|
        require "stradivari/table/builder/#{id}_builder"
        memo[id] = const_get(name)
      end.freeze
    end
  end
end
