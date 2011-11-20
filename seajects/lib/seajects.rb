require 'rubygems'
require 'tempfile'
require 'json'

class Seajects
  include Enumerable

  class Element
    include Enumerable
    attr_accessor :children, :line, :name, :parent, :type

    def to_json(*args)
      to_hash.to_json(*args)
    end

    def initialize(name)
      @name = name
      @children = {}
    end

    def add(child)
      self[child.name] = child
    end

    def each(&block)
      yield self
      @children.each_value do |child|
        child.each &block
      end
    end

    def [](name)
      @children[name]
    end

    def []=(name, child)
      child.parent = self
      @children[name] = child
    end

    def to_id()
      return @name if @parent.nil?
      @parent.to_id + '::' + @name
    end

    def to_hash()
      {
        :line => line,
        :name => name,
        :type => type,
        :children => children
      }
    end
  end

  # Parse file at given path and return the model elements.
  #
  # path - The String path to a file
  #
  # Examples
  #
  #   Seaject.parse_path("/tmp/files/foo.rb")
  #
  # Returns a Hash of elements.
  def Seajects.parse_path(path)
    parser = Seajects.new path
    parser.parse_tags
  end

  # Parse given content and return the model elements.
  #
  # name - The String name of the content being parsed
  # content - The String content to parse tags for
  #
  # Examples
  #
  #   Seaject.parse_content("Main.java", "public String toString() {}")
  #
  # Returns a Hash of elements.
  def Seajects.parse_content(name, content)
    base = File.basename name
    ext = File.extname base
    temp = Tempfile.new [base, ext]
    temp.write content
    temp.close
    begin
      parsed = parse_path temp.path
    ensure
      temp.unlink
    end
    parsed
  end

  # Parse file at given path and return json.
  #
  # path - The String path to a file
  #
  # Examples
  #
  #   Seaject.from_path("/tmp/files/foo.rb")
  #
  # Returns a JSON String of the model elements
  def Seajects.from_path(path)
    parsed = parse_path path
    parsed.to_json
  end

  # Parse given content and return json.
  #
  # name - The name of the file
  # content - The String content to parse
  #
  # Examples
  #
  #   Seaject.from_content("Main.java", "public String toString() {}")
  #
  # Returns a JSON String of the model elements
  def Seajects.from_content(name, content)
    parsed = parse_content name, content
    parsed.to_json
  end

  # Index of element name
  NAME = 0
  # Index of element line number
  LINE = 2
  # Index of element type
  TYPE = 3
  # Index of parent
  PARENT = 4

  attr_reader :path, :tags

  def initialize(path)
    @path = path
    @tags = {}
  end

  # Parse tags at configured file path and return model elements
  #
  # Returns a Hash of the model elements keyed on the element names
  def parse_tags
    result = `ctags --fields=+K -nf - #{@path}`
    raise "ctags did not sucessfully complete" unless $?.exitstatus == 0
    elements = {}
    if !result.nil? && result.length > 0
      result.each do |line|
        line.strip!
        sections = line.split("\t")
        case sections.length
        when 4, 5
          parse_element sections, elements
        else
          raise "ctags line did not contain at least 4 sections"
        end
      end
    end
    @tags = elements
  end

  def each(&block)
    @tags.each_value do |tag|
      tag.each &block
    end
  end

  def to_json(*args)
    @tags.to_json
  end

  private

  def parse_line_number(sections)
    Integer sections[LINE].chop!.chop!
  end

  def parse_parent_path(path)
    path = path[6..-1] if path.start_with? "class:"
    path.split '.'
  end

  def add_element(name, parent)
    element = parent[name]
    if element.nil?
      element = Element.new name
      parent[name] = element
    end
    element
  end

  def parse_element(sections, roots)
    element = nil
    parent = nil
    if !sections[PARENT].nil?
      segments = parse_parent_path sections[PARENT].to_s
      parent = add_element segments.shift, roots
      segments.each do |name|
        parent = add_element name, parent
      end
    else
      parent = roots
    end

    element = add_element sections[NAME], parent
    element.type = sections[TYPE]
    element.line = parse_line_number sections
  end

end
