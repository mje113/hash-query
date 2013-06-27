[![Build Status](https://travis-ci.org/[mje113]/[hash-query].png)](https://travis-ci.org/[mje113]/[hash-query])
[![Code Climate](https://codeclimate.com/github/mje113/hash-query.png)](https://codeclimate.com/github/mje113/hash-query)

# Hash Query

Provides a css-like selector system for querying values out of deeply nested hashes.

## Usage

```ruby
require 'hash_query'

hash = { 
  a: 1, 
  b: { 
    c: {
      d: { 
        e: 2, 
        f: 3 
      }
    },
    cc: [
      3,
      {
        g: 6,
        h: 7,
        i: => [ 8, 9, 10, 11 ]
      },
      4,
      5
    ]
  }
}
```

Requiring hash_query will provide two new methods, Hash#query_value and Hash#query_values.  Both methods take a single string to represent a key or keys to be found in the hash.

To find a the first key match:
```ruby
hash.query_value('e')   # => 2
hash.query_value('c d') # => { e: 2, f: 3 }
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
