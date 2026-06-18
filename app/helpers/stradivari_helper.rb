require 'stradivari/haml_compat'

module StradivariHelper
  # haml_tag / haml_concat / capture_haml were removed in Haml 6; stradivari's
  # generators still call them on the view, so the gem provides them. See
  # Stradivari::HamlCompat. (Consumers no longer need an app-side shim.)
  include Stradivari::HamlCompat

  def table_for *args, &block
    Stradivari::Table::Generator.new(self, *args, &block).to_s
  end

  def csv_for *args, &block
    Stradivari::CSV::Generator.new(self, *args, &block).to_s
  end

  def xlsx_for *args, &block
    Stradivari::XLSX::Generator.new(self, *args, &block).to_s
  end

  def details_for *args, &block
    Stradivari::Details::Generator.new(self, *args, &block).to_s
  end

  def filter_for *args, &block
    Stradivari::Filter::Generator.new(self, *args, &block).to_s
  end

  def tabs_for(*args, &block)
    Stradivari::Tabs::Generator.tabs(self, *args, &block).to_s
  end

  def tab_navs_for(*args, &block)
    Stradivari::Tabs::Generator.navs(self, *args, &block).to_s
  end

  def tab_content_for(*args, &block)
    Stradivari::Tabs::Generator.content(self, *args, &block).to_s
  end

  def search_param(name)
    params[Stradivari::Filter::NAMESPACE].try(:[], name).presence
  end

  def select_tree_check_box(*args)
    name, value, checked, options =
      if args.first.is_a?(Hash)
        [nil, nil, false, args.first]
      elsif args.size == 3
        [*args, {}]
      elsif args.size == 4
        args
      else
        raise ArgumentError, "Wrong number of arguments (#{args.size}) for (1, 3..4)"
      end

    data = { bind: 'select-tree', select_tree_name: options.fetch(:name) }
    data[:select_tree_parent]      = options[:parent]      if options[:parent]
    data[:select_tree_count_total] = options[:count_total] if options[:count_total]

    check_box_tag(name, value, checked, data: data, id: options[:name])
  end

end
