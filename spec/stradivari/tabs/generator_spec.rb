# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Stradivari::Tabs::Generator do
  describe 'rendering tabs' do
    it 'renders nav and content with default flavor (tabs)' do
      view = view_context
      out = view.tabs_for([1, 2, 3]) do |scope|
        tab 'First',  'first', scope, present: true do |s|
          haml_concat "Count: #{s.count}"
        end
        tab 'Second', 'second', [], present: false do |_|
          haml_concat 'Nothing'
        end
      end

      doc = Nokogiri::HTML.fragment(out)
      expect(doc.at_css('ul.nav.nav-tabs')).not_to be_nil
      expect(doc.at_css('.tab-content')).not_to be_nil
      expect(doc.css('ul.nav-tabs li').size).to eq(1) # second tab is blank+!present
      expect(doc.at_css('.tab-pane.active')).not_to be_nil
      expect(doc.at_css('.tab-pane#first')).not_to be_nil
    end

    it 'renders the pills flavor when requested' do
      view = view_context
      out = view.tabs_for([1], flavor: :pills) do |scope|
        tab 'Only', 'only', scope do |_|
          haml_concat 'X'
        end
      end
      expect(out).to include('nav-pills')
    end

    it 'sanitises dom_ids with css_friendly' do
      view = view_context
      out = view.tabs_for([1]) do |s|
        tab 'A', 'foo[bar].baz', s do |_|
          haml_concat 'x'
        end
      end
      expect(out).to include('id=\'foo_bar__baz\'').or include('id="foo_bar__baz"')
    end

    it 'renders the blank fallback when all tabs are blank' do
      view = view_context
      out = view.tabs_for([]) do |_|
        blank { haml_tag :div, 'Nothing here', class: 'empty' }
        tab 'Empty', 'empty', [] do |_|
          haml_concat 'never'
        end
      end
      doc = Nokogiri::HTML.fragment(out)
      expect(doc.at_css('div.empty')).not_to be_nil
      expect(doc.at_css('ul.nav-tabs')).to be_nil
    end

    it 'renders counters by default and hides them when counters: false' do
      view = view_context
      with_counters = view.tabs_for([1, 2, 3]) do |s|
        tab 'A', 'a', s do |_|
          haml_concat 'x'
        end
      end
      no_counters = view.tabs_for([1, 2, 3], counters: false) do |s|
        tab 'B', 'b', s do |_|
          haml_concat 'x'
        end
      end
      expect(with_counters).to include('badge')
      expect(no_counters).not_to include('badge')
    end
  end

  describe '.navs and .content' do
    it 'tab_navs_for renders only the navigation' do
      view = view_context
      out = view.tab_navs_for do
        tab 'Only', 'only', [1] do |_|
          haml_concat 'x'
        end
      end
      expect(out).to include('nav-tabs')
      expect(out).not_to include('tab-content')
    end

    it 'tab_content_for renders only the panes' do
      view = view_context
      out = view.tab_content_for do
        tab 'Only', 'only', [1] do |_|
          haml_concat 'x'
        end
      end
      expect(out).to include('tab-content')
      expect(out).not_to include('nav-tabs')
    end
  end

  describe 'misc options' do
    it 'honours per-tab :counter override' do
      view = view_context
      out = view.tabs_for([1, 2, 3]) do |s|
        tab 'A', 'a', s, counter: 99 do |_|
          haml_concat 'x'
        end
      end
      expect(out).to include('>3<') # @content responds to count → uses count, not raw counter
    end

    it 'renders printable layout when printable: true' do
      view = view_context
      out = view.tabs_for([1], printable: true) do |s|
        tab 'A', 'a', s do |_|
          haml_concat 'X'
        end
      end
      expect(out).to include('X')
      expect(out).not_to include('nav-tabs')
    end

    it 'tab_content alias forwards to tab' do
      view = view_context
      out = view.tabs_for([1]) do |_|
        tab_content 'a', [1] do |_|
          haml_concat 'aliased'
        end
      end
      expect(out).to include('aliased')
    end
  end
end
