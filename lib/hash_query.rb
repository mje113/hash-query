require 'hash_query/version'
require 'pry'

class Hash
  include HashQuery::HashExtension
end

module HashQuery

  module HashExtension

    # Public: Scans the hash data strucure looking for keys that match the 
    # psuedo css selector.
    #
    # selectors - String of pseudo css selectors to navigate hash structure
    #
    # Examples
    #
    #     entity = { 
    #       :a => 1, 
    #       :b => { 
    #         :c => {
    #           :d => { 
    #             :e => 2, 
    #             :f => 3 
    #           }
    #         },
    #         :cc => [
    #           3,
    #           {
    #             :g => 6,
    #             :h => 7,
    #             :i => [ 8, 9, 10, 11 ]
    #           },
    #           4,
    #           5
    #         ]
    #       }
    #     }.to_entity
    #     entity.query('a')         # => 1
    #     entity.query('a b c d e') # => 2
    #     entity.query('c d e')     # => 2
    #
    # Returns a value or collection of values that are found.
    def query(selectors)
      @_query ||= HashQuery::Query.new(self)
      @_query.query(selectors)
      
      selectors = selectors.split(/ /)
      found = _descend(selectors, self, [])
  
      if found.empty?
        nil
      elsif found.size == 1
        found.first
      else
        found
      end
    end

  end

  class Query

    def _hash_y?(node)
      node.class.ancestors.include?(Hash)
    end
  
    def _array_y?(node)
      node.class.ancestors.include?(Array)
    end
  
    def _descend(selectors, node, found)
      return if node.nil? || (!_hash_y?(node) && !_array_y?(node))
      _descend_array(selectors, node, found) if _array_y?(node)
      _descend_hash(selectors, node, found)  if _hash_y?(node)
      return found
    end
  
    def _descend_array(selectors, node, found)
      node.each do |a|
        _descend(selectors, a, found)
      end
    end
  
    def _selector_with_type(selector)
      selector.split(':')
    end
  
    def _descend_hash(selectors, node, found)
      selectors = selectors.dup
  
      key, type = _selector_with_type(selectors.first)
      #Object.module_eval("::#{$1}", __FILE__, __LINE__)
      if node.has_key?(key) && node[key].is_a?(type)
        selectors.shift
        if selectors.size == 0
          found << node[key]
        else
          _descend(selectors, node[key], found)
        end
      else
        node.select { |k, node| _hash_y?(node) || _array_y?(node) }.each do |k, node| 
          _descend(selectors, node, found)
        end
      end
    end
  end

end
