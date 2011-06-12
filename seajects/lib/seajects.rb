require 'rubygems'
require 'json'

class Element
  attr_accessor :line, :name, :parent, :type

  def to_json(*args)
    to_hash.to_json(*args)
  end

  protected

  def to_hash()
    {
      :line => line,
      :name => name,
      :type => type
    }
  end
end

class Container < Element
  attr_reader :children

  def initialize()
    @children = []
  end

  def add(child)
    @children.push child
    child.parent = self
    self
  end

  def to_json(*args)
    hash = to_hash
    hash[:children] = @children
    hash.to_json(*args);
  end
end

class Seajects

  # Parse file at given path and return the model elements.
  #
  # path - The String path to a file
  #
  # Examples
  #
  #   Seaject.parse("/tmp/files/foo.rb")
  #
  # Returns a Hash of elements.
  def Seajects.parse(path)
    parser = Seajects.new path
    parser.parse_tags
  end

  # Parse file at given path and return json.
  #
  # path - The String path to a file
  #
  # Examples
  #
  #   Seaject.to_json("/tmp/files/foo.rb")
  #
  # Returns a JSON String of the model elements
  def Seajects.to_json(path)
    parse(path).to_json
  end

  # Index of element name
  NAME = 0
  # Index of element line number
  LINE = 2
  # Index of element type
  TYPE = 3

  attr_reader :path

  def initialize(path)
    @path = path
  end

  # Parse tags at configured file path and return model elements
  #
  # Returns a Hash of the model elements keyed on the element names
  def parse_tags
    result = `ctags --fields=+K -nf - #{@path}`
    if $?.exitstatus != 0
      raise "ctags did not sucessfully complete"
    end
    if result.nil? || result.length == 0
      return {}
    end
    elements = {}
    result.each { |line|
      line.strip!
      sections = line.split("\t")
      case sections.length
      when 4
        parse_container sections, elements
      when 5
        parse_element sections, elements
      else
        raise "ctags line did not contain at least 4 sections"
      end
    }
    elements
  end

  def to_json(*args)
    elements
  end

  private

  def parse_line_number(sections)
    Integer(sections[LINE].chop!.chop!)
  end

  def parse_element(sections, roots)
    element = Element.new
    element.name = sections[NAME]
    element.type = sections[TYPE]
    element.line = parse_line_number sections

    parent = sections[4].to_s
    if parent.start_with?("class:")
      parent = parent[6..-1]
    end
    parent = roots[parent]
    if !parent.nil?
      parent.add element
    else
      roots[element.name] = element
    end
  end

  def parse_container(sections, roots)
    container = Container.new
    container.name = sections[NAME]
    container.type = sections[TYPE]
    container.line = parse_line_number sections
    roots[container.name] = container
  end

end
