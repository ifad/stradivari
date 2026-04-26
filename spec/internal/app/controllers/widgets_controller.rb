class WidgetsController < ApplicationController
  include Stradivari::Controller
  include Stradivari::XLSX::Controller

  stradivari_filter Widget, default_sorting: 'name', default_direction: 'ASC'

  def index
    @widgets = Widget.stradivari_filter(stradivari_filter_options)

    respond_to do |format|
      format.html { render inline: index_template, type: :haml }
      format.csv  { render inline: csv_template,   type: :haml }
      format.xlsx { render_xlsx inline: xlsx_template, type: :haml, filename: 'widgets' }
    end
  end

  def show
    @widget = Widget.find(params[:id])
    render inline: details_template, type: :haml
  end

  private

  def index_template
    <<~HAML
      = filter_for(Widget) do
        - search :name_like
        - selection :kind, collection: Widget::KINDS
        - boolean :active
        - number :priced_above
        - search :search, active: -> { true }
        - checkbox :kind_chk, collection: Widget::KINDS.dup
        - date_range :released_on
        - custom :custom_field, active: -> { false } do |attr, opts|
          %div.custom-field= attr
      = table_for(@widgets, downloadable: :xlsx) do
        - row do |attrs, w|
          - attrs['data-widget-id'] = w.id
        - column :id
        - column :name, sortable: true, type: :text_link
        - column :price
        - column :active
        - column :released_on
        - column :description, present: true
        - column :actions, actions: [:show]
      = tabs_for(@widgets, flavor: :tabs, counters: true) do |widgets|
        - tab "All", "all_widgets", widgets do
          %p All widgets shown.
    HAML
  end

  def csv_template
    <<~HAML
      = csv_for(@widgets) do
        - column :id
        - column :name
        - column :price
    HAML
  end

  def xlsx_template
    <<~HAML
      = xlsx_for(@widgets) do
        - column :id
        - column :name
        - column :price
    HAML
  end

  def details_template
    <<~HAML
      = details_for(@widget) do
        - field :name
        - field :price
        - field :released_on
        - field :description, present: true
    HAML
  end
end
