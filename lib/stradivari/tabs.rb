module Stradivari::Tabs

  autoload :Generator, 'stradivari/tabs/generator'

  module Dislocated
    autoload :NavGenerator, 'stradivari/tabs/dislocated/nav_generator'
    autoload :ContentGenerator, 'stradivari/tabs/dislocated/content_generator'
  end

end
