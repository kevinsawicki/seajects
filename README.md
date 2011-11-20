# seajects - Generate object models from ctags

seajects parses the `ctags` output into a tree hierarchy.

## Examples

### Parse an existing file and find all methods

```ruby
tags = Seajects.from_file '/data/src/Buffer.cpp'
methods = tags.find_all do |tag|
  'method' == tag.name
end
```

### Parse raw content and print classes found

```ruby
content = "class Stream\n"
content += "class Buffer\n"
content += "end\n"
content += "end\n"
tags = Seajects.from_content "stream.rb", content
tags.each do |tag|
  puts "Class #{tag.name} at line #{tag.line}" if 'class' == tag.type
end
```ruby

## License

[MIT License](http://www.opensource.org/licenses/mit-license.php)

