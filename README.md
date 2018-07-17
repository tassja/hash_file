# hash_file

A hash function that persists its data onto disk. Useful when creating a simple cache

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  hash_file:
    github: mehmetc/hash_file
```

## Usage

```crystal
require "hash_file"

HashFile.config({"base_dir" => "/tmp/cache"})
HashFile["hello"] = "world"
HashFile.store("foo", "bar", {"expire" => (Time.now + 5.minute)}) #5 minutes
puts HashFile["hello"]
HashFile.fetch("foo") unless HashFile.expired?("foo")
HashFile.delete("hello")
HashFile.clear
```

## Contributing

1. Fork it (<https://github.com/your-github-user/hash_file/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [mehmetc](https://github.com/mehmetc) Mehmet Celik - creator, maintainer
