#convert an expire time into seconds since epoch
#accepts a Time object or a String in the form of "2018-01-01 12:00:00 +2:00"
module ExpireTime
    extend self
    
    def to_epoch(raw_expire : Time)
        raw_expire.epoch
    end

    def to_epoch(raw_expire : String)
        Time.parse(raw_expire, "%F %T %:z").epoch
    end

    def is_expired?(epoch_time : Int64 | Nil = Time.now)
        return false if epoch_time.nil?
        Time.now > Time.epoch(epoch_time)
    end

end