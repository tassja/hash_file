require "./spec_helper"

base_dir = "./cache"
key = "hello"
key_hash = "5d/41402abc4b2a76b9719d911017c592"
key_hash_path = "./cache/#{key_hash}"
value = "world"

HashFile.config({"spread" => 0, "base_dir" => base_dir})


describe HashFile do
  it "hashes a key" do    
    HashFile.to_filename(key).should eq(key_hash_path)
  end

  it "should return false if the key is not present on disk" do
    HashFile.key?(key).should be_false
  end

  it "should return true if the key is present on disk" do
    HashFile[key] = value
    HashFile.key?(key).should be_true

    FileUtils.rm_r(base_dir)
  end

  it "should take a spread of 0" do
    HashFile.config({"spread" => 0})
    HashFile.to_filename(key).should eq(key_hash_path)
  end 

  it "should create an entry" do
    HashFile[key] = value
    File.exists?(key_hash_path).should be_true
    FileUtils.rm_r(base_dir)
  end

  it "should have ./cache as the base_dir" do
    HashFile.config["base_dir"].should eq(base_dir)
  end

  it "should have a spread of 0" do
    HashFile.config["spread"].should eq(0)
  end  

  it "should delete a key" do
    HashFile[key] = "world"
    HashFile.delete(key).should be_true
  end

  it "should return the value of a stored key" do
    HashFile[key] = value
    HashFile[key].should eq(value)
    HashFile.delete(key)
  end

  it "should expire after 3 seconds" do
    t = Time.now + Time::Span.new(0,0,3)
    HashFile.store(key, value, {"expire" => t})
    sleep 4
    HashFile[key].should be_nil
  end

  it "key should be expired" do
    t = Time.now + Time::Span.new(0,0,3)
    HashFile.store(key, value, {"expire" => t})
    HashFile.expired?(key).should be_false
    sleep 4
    HashFile.expired?(key).should be_true
  end

  it "should not expire after 3 seconds" do
    t = Time.now + Time::Span.new(0,0,30)
    HashFile.store(key, value, {"expire" => t})
    sleep 4
    HashFile[key].should eq(value)
    FileUtils.rm_r(base_dir)
  end
end
