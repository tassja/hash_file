#convert an expire time into seconds since epoch
#accepts a Time object or a String in the form of "2018-01-01 12:00:00 +2:00"
module ExpireTime
    extend self

    def to_epoch(raw_expire : Time)
        raw_expire.to_unix
    end

    def to_epoch(raw_expire : String)
        Time.parse(raw_expire, "%F %T %:z", Time::Location.local).to_unix
    end

    def is_expired?(epoch_time : Int64 | Nil = Time.local)
        return false if epoch_time.nil?
        Time.local > Time.unix(epoch_time)
    end

end
