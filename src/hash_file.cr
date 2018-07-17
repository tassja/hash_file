require "./hash_file/*"
require "digest/md5"
require "json"

# HashFile stores data into a file
module HashFile
  extend self
  @@config = {"spread" => 2, "base_dir" => "/tmp"}

  # overwrite default configuation settings
  # spread: the amount of sub directories to transform the key hash into
  # base_dir: where should your cache be located
  def config(options : (Hash(String, String | Number)) = {} of String => String | Int32)
    options.each do |k, v|
      @@config[k] = v
    end

    @@config
  end

  # converts a key into a hash
  def to_filename(value : String, ommit_base_dir : Bool = false)
    base_dir = ommit_base_dir ? "" : @@config["base_dir"].to_s
    File.join(base_dir, spread(md5(value), @@config["spread"].to_i))
  end

  # does your key exists
  def key?(value : String)
    File.exists?(to_filename(value))
  end

  # get value for a given key
  def [](key : String)
    fetch(key, {} of String => String)
  end

  # get value for a given key.
  def fetch(key : String, options : Hash(String, String | Int32 | Time))
    return nil unless key?(key)
    data = JSON.parse(File.read("#{to_filename(key)}_metadata"))

    if ExpireTime.is_expired?(data["expire"].as_i64?)
      FileUtils.rm_r(to_filename(key))
      return nil    
    end

    File.read(to_filename(key))
  end

  #set value for a given key
  def []=(key : String, value : String | Number | Time)
    store(key, value, {} of String => String)
  end

  #set value for a given key
  def store(key : String, value : String | Number | Time, options : Hash(String, String | Int32 | Time))
    expire : Int64 | Nil = options.has_key?("expire") ? ExpireTime.to_epoch(options["expire"]) : nil

    key_hash : String = to_filename(key)
    data = {timestamp: Time.now.epoch, expire: expire, key: key}
    file_path = File.dirname(key_hash)
    file_name = File.basename(key_hash)

    Dir.mkdir_p(file_path) unless Dir.exists?(file_path)
    File.open("#{key_hash}_metadata", "wb") do |f|
      f.puts data.to_json
    end
    File.open(key_hash, "wb") do |f|
      f.write value.to_slice
    end
    true
  rescue e
    puts e.message
    false
  end

  #delete a key
  def delete(key : String)
    key?(key) ? FileUtils.rm_r(to_filename(key)).nil? : false
  end

  #check if a key is expired
  def expired?(key : String)
    fetch(key, {} of String => String).nil?
  end

  #flush files from disk
  def clear
    dir = @@config["base_dir"].to_s
    if dir.eql?("/") || dir.eql?("./")
      return false      
    end
    FilUtils.rm_r("#{dir}/*")
    true
  end

  # calculate md5 hash
  private def md5(key : String)
    Digest::MD5.hexdigest(key)
  end

  # return the spread of a hash. This is used to create the directory path
  # for example: ```key = 9bfe76a98dc06a5d1658e5b060072297``` with a spread level of 0
  # return ```9b/fe76a98dc06a5d1658e5b060072297``` and a spread level of 1 ```9b/fe/76a98dc06a5d1658e5b060072297```
  private def spread(value : String, level : Number = 0)
    data = level > 0 ? spread(value[2..-1], level -= 1) : value[2..-1]
    File.join(value[0..1], data)
  end

end
