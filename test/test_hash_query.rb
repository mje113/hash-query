require 'helper'

class TestHquery_value < MiniTest::Unit::TestCase

  def setup
    @movie = {
      'title'  => 'Goodfellas',
      'rating' => 'R',
      'encodings' => ['a', 'b', 'c'],
      'media'  => [
        {
          'type' => 'hd',
          'encoding' => 'h264'
        },
        {
          'type' => 'sd',
          'encoding' => 'mpeg2'
        }
      ],
      'actors' => [
        {
          'name' => 'Robert De Niro',
          'role' => 'James Conway',
          'awards' => {
            'academy' => 2,
            'emmies'  => 5
          }
        },
        {
          'name' => 'Ray Liotta',
          'role' => 'Henry Hill'
        }
      ],
      'director' => {
        'name' => 'Martin Scorsese',
        'award_count' => 23
      }
    }

    @hquery = { 
          'a' => 1, 
          'b' => { 
            'c' => {
              'd' => { 
                'e' => 2, 
                'f' => 3 
              }
            },
            'cc' => [
              3,
              {
                'g' => 6,
                'h' => 7,
                'i' => [ 8, 9, 10, 11 ]
              },
              4,
              5
            ]
          }
        }
  end

  def test_included_in_hash
    h = {}
    assert h.respond_to?(:query_value)
    assert h.respond_to?(:query_values)
  end

  def test_finds_nothing
    assert_nil @hquery.query_value('z')
  end

  def test_finding_deep_array_value
    assert_equal [8,9,10,11], @hquery.query_value('i')
  end

  def test_can_be_querried_shallow
    assert_equal 'Goodfellas', @movie.query_value('title')
    assert_equal 'R',          @movie.query_value('rating')
  end

  def test_can_be_querried_one_level_deep
    assert_equal 'Martin Scorsese', @movie.query_value('director name')
  end

  def test_can_be_querried_shallow_for_a_deep_value
    assert_equal 23, @movie.query_value('award_count')
  end

  def test_can_be_querried_two_levels_deep
    assert_equal 2, @movie.query_value('actors awards academy')
    assert_equal 5, @movie.query_value('actors awards emmies')
  end

  def test_can_be_querried_to_find_an_array
    assert_equal ['a', 'b', 'c'], @movie.query_value('encodings')
  end
   
  def test_can_be_querried_for_multiple_values
    assert_equal ['Robert De Niro', 'Ray Liotta'], @movie.query_values('actors name')
  end

  def test_can_be_querried_for_one_value_when_multiple_exist
    assert_equal 'Robert De Niro', @movie.query_value('actors name')
  end

  def test_can_query_for_type
    assert_equal 'Goodfellas', @movie.query_value('title:string')
  end

  def test_can_deep_query_for_type
    assert_equal 2, @movie.query_value('academy:fixnum')
    assert_equal 2, @movie.query_value('actors awards academy:fixnum')
  end

  def test_will_return_nil_if_type_is_not_matched
    assert_equal nil, @movie.query_value('title:fixnum')
  end

  def test_can_query_for_complex_type
    assert_equal ['a', 'b', 'c'], @movie.query_value('encodings:array')
  end

  def test_raises_exception_if_type_not_found
    assert_raises NameError do
      @movie.query_value('title:bogus')
    end
  end

  def test_changed_hash_after_initialization
    hash = { 'a' => 1, 'b' => 2, 'c' => 3 }
    assert_equal 2, hash.query_value('b')
    hash['b'] = 3
    assert_equal 3, hash.query_value('b')
  end

end
