require 'hash_query/version'

module HashQuery

  module Extension

    # Public: Scans the hash data strucure looking for keys that match the 
    # psuedo css selector.
    #
    # selectors - String of pseudo css selectors to navigate hash structure
    #
    # Examples
    #
    #     hash = { 
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
    #     }
    #     hash.query_values('a')         # => 1
    #     hash.query_values('a b c d e') # => 2
    #     hash.query_values('c d e')     # => 2
    #     hash.query_values('a>string')
    #     hash.query_values('a:string')
    #
    # Returns a value or collection of values that are found.
    def query_values(selectors)
      @_query ||= HashQuery::Query.new(self)
      @_query.query(selectors)
    end

    def query_value(selectors)
      values = query_values(selectors)
      values && values.first
    end

  end

  class Query

    def initialize(hash)
      @hash = hash
    end

    def query(selectors)
      selectors = Selector.parse(selectors)
      found = descend(selectors, @hash, [])
  
      if found.empty?
        nil
      else
        found
      end
    end

    def hash_y?(node)
      node.class.ancestors.include?(Hash)
    end
  
    def array_y?(node)
      node.class.ancestors.include?(Array)
    end
  
    def descend(selectors, node, found)
      return if node.nil? || (!hash_y?(node) && !array_y?(node))
      descend_array(selectors, node, found) if array_y?(node)
      descend_hash(selectors, node, found)  if hash_y?(node)
      return found
    end
  
    def descend_array(selectors, node, found)
      node.each do |a|
        descend(selectors, a, found)
      end
    end
  
    def descend_hash(selectors, node, found)
      selectors = selectors.dup

      if selectors.first.match?(node)
        selector = selectors.shift
        if selectors.size == 0
          found << selector.match!(node)
        else
          descend(selectors, selector.match!(node), found)
        end
      else
        node.select { |k, node| hash_y?(node) || array_y?(node) }.each do |k, node| 
          descend(selectors, node, found)
        end
      end
    end
  end

  class Selector

    def self.parse(selectors)
      selectors.split(/ /).map { |matcher| new(matcher) }
    end

    def initialize(matcher)
      @key, @type = matcher.split(':')
      if @type
        @type = case @type
                when 'boolean'
                  [FalseClass, TrueClass]
                else
                  [Object.module_eval("::#{@type.capitalize}", __FILE__, __LINE__)]
                end
      end
    end

    def match?(node)
      node.has_key?(@key) && (!@type || @type.any? { |type| node[@key].is_a?(type) })
    end

    def match!(node)
      node[@key]
    end
  end

end

class Hash
  include HashQuery::Extension
end
