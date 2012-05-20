require 'hash_query/version'
require 'pry'

class Hash
  include HashQuery
end

module HashQuery

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
  #     entity.value_at('a')         # => 1
  #     entity.value_at('a b c d e') # => 2
  #     entity.value_at('c d e')     # => 2
  #     entity.value_at('e:2')       # => 2
  #     entity.value_at('e:1')       # => nil
  #     entity.value_at('e:2>f')     # => 3
  #
  # Returns a value or collection of values that are found.
  def query(selectors)
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

  protected

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

  def _descend_hash(selectors, node, found)
    selectors = selectors.dup
    
    # normalize symbol and string keys
    key = node.has_key?(selectors.first.to_sym) ? 
      selectors.first.to_sym : selectors.first
    
    if node.has_key?(key)
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
