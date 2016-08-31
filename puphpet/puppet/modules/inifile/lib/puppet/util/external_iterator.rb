module Puppet
module Util
  class ExternalIterator
    def initialize(coll)
      @coll = coll
      @cur_index = -1
    end

    def next
      @cur_index = @cur_index + 1
      item_at(@cur_index)
    end

    def peek
      item_at(@cur_index + 1)
    end

    private
    def item_at(index)
      if @coll.length > index
        [@coll[index], index]
      else
        [nil, nil]
      end
    end
  end
end
end
