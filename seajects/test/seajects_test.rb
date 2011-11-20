require 'test/unit'
require 'lib/seajects'

class TestSeajects < Test::Unit::TestCase

  def test_ruby_parsing
    file = File.expand_path __FILE__
    assert_not_nil file
    tags = Seajects.parse_path file
    assert_not_nil tags
    assert tags.length == 1
    name = self.class.name
    tag = tags[name]
    assert_not_nil tag
    assert_equal name, tag.name
    assert tag.line > 0
    assert_not_nil tag.type
    assert_not_nil tag.children
    assert tag.children.length > 0
  end

  def testfrom_content
    tags = Seajects.parse_content "Main.java", "public String toString() {}"
    assert_not_nil tags
    assert tags.length == 1
    tag = tags["toString"]
    assert_not_nil tag
    assert_equal "toString", tag.name
    assert_equal 1, tag.line
    assert_equal "method", tag.type
    assert tag.line > 0
    assert_not_nil tag.type
    assert_not_nil tag.children
    assert_equal 0, tag.children.length
  end
end