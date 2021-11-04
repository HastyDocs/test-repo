some text - ruby
some text - #-------------------------------------------------------------------------
some text - # Copyright (c) Microsoft. All rights reserved.
some text - #--------------------------------------------------------------------------
some text - 
some text - module Azure
  module Blob
    class Blob

      def initialize
        @properties = {}
        @metadata = {}
        yield self if block_given?
      end

      attr_accessor :name
      attr_accessor :snapshot
      attr_accessor :properties
      attr_accessor :metadata
      attr_accessor :TEST_BY_MAREK
      attr_accessor :TEST_BY_MAREK_ATTEMPT_2
    end
  end
end
