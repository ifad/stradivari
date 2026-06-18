module Stradivari
  # Haml 5 mixed `haml_tag` / `haml_concat` / `capture_haml` into every view via
  # `Haml::Helpers`. Haml 6 removed them. Stradivari's generators (table / tabs /
  # filter / details builders) still call these on the view, so the gem now
  # ships its own thin reimplementation over ActionView's
  # `capture` / `content_tag` / `output_buffer`. Mixed into the view through
  # {StradivariHelper}, so consumers no longer need an app-side shim.
  #
  # Semantics match Haml 5:
  #   haml_concat(text)           -> append text to the current output buffer
  #   haml_tag(name, *args, &blk) -> build a tag (optional text + attr hash,
  #                                  optional nested block) and append it
  #   capture_haml(&blk)          -> capture the block's buffer output as a
  #                                  string without appending it
  # Each method defers to the native Haml helper (`super`) when one is present —
  # i.e. on Haml 5, where `Haml::Helpers` still mixes these into the view below
  # StradivariHelper in the ancestor chain. Only on Haml 6+ (helpers removed, no
  # `super`) does the reimplementation kick in. This keeps consumers still on
  # Haml 5 / older Rails working unchanged.
  module HamlCompat
    def haml_concat(text = "")
      return super if defined?(super)
      output_buffer << (text.nil? ? "" : text.to_s)
      nil
    end

    def haml_tag(name, *args, &block)
      return super if defined?(super)
      attributes = args.last.is_a?(Hash) ? args.pop : {}
      text       = args.first

      content = block_given? ? capture(&block) : text
      output_buffer << content_tag(name.to_s, content, attributes)
      nil
    end

    def capture_haml(*args, &block)
      return super if defined?(super)
      # with_output_buffer swaps in a fresh buffer, runs the block, returns what
      # was written. `.to_s` so callers that String-massage the result work.
      #
      # Stradivari's tabs generator `instance_exec`s its definition/blank/tab
      # blocks in the GENERATOR's context, but Haml 6 compiles their plain text
      # to `@output_buffer.safe_concat` — and the generator's @output_buffer is
      # nil. Point the block receiver's @output_buffer at the buffer we just
      # swapped in so those writes land here.
      with_output_buffer do
        receiver = block.binding.receiver
        if receiver && receiver != self && receiver.respond_to?(:view, true)
          receiver.instance_variable_set(:@output_buffer, output_buffer)
        end
        block.call(*args)
      end.to_s
    end
  end
end
