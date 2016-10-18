module DirectoryTools
  require 'ldap'
  require 'timeout'
  
  class Ldap
    DEFAULT_HOST = "ldap.williams.edu"
    DEFAULT_BASE = "ou=people,o=williams"
    DEFAULT_SCOPE = LDAP::LDAP_SCOPE_SUBTREE
    DEFAULT_FILTER_KEY = "uid"
    DEFAULT_FILTER_VALUE = "*"
    
    def initialize(dn=nil, pw=nil, host = DEFAULT_HOST)
      @ldap = LDAP::Conn.new(host)
      @ldap.bind(dn, pw) if dn && pw
    end
    
    def Ldap.can_show?(entry)
      entry["ODIRstatus"] == "A"
    end
    
    def each_possible(key = DEFAULT_FILTER_KEY, base = DEFAULT_BASE, scope = DEFAULT_SCOPE, g = OitUsernameGenerator.new)
      g.each do |un|
        each_user(key, un, base, scope) { |u| yield(u) }
      end
    end
    
    def each_user(key = DEFAULT_FILTER_KEY, value = DEFAULT_FILTER_VALUE, base = DEFAULT_BASE, scope = DEFAULT_SCOPE)
      # This yields a Hash for each user matching un
      @ldap.search2(base, scope, "(#{key}=#{value})") do |e|
        e.each_key { |k| e[k] = e[k].first }
        #e[:visible] = Ldap.can_show?(e)
        yield(e)
#        else
#          e.delete_if { |k,v| ! %w( uid cn mail ou ).include?(k) }
#          e[:visible] = false
#          yield(e)
#        end
      end
    end

  end
  
  # Ph
  # Benjamin Wood, Williams Students Online
  # (c) 2007 Williams Students Online
  # A rough translation of PH.java, by Michael Gnozzio and Aaron Schwartz
  # note that Ph makes a new connection on each query, since the OIT PH server times out...
  
  require 'socket'
  class Ph
    
    def initialize(host = "ns.williams.edu", port = 105)
      @host = host
      @port = port
      @sock = TCPSocket.new(host, port)
      @queries = 0
      #puts "connected"
    end
    
    def disconnect
      @sock.puts("quit")
      @sock.close
    end
    
    # return an array of matching records
    def query(q)
      Timeout::timeout(1) {
        @queries += 1
        if @queries >= 999
          disconnect
  	     @sock = TCPSocket.new(@host, @port)
      	 @queries = 0
        end
        #puts "querying..."
        @sock.puts("query #{q} return all")
        #puts "getting response..."
        resp = @sock.gets
        #puts resp
        while (resp.match(/^Connection\sclosed\sby\sforeign\host\./))
          @sock = TCPSocket.new(@host, @port)
  	     @queries = 0
          @sock.puts("query #{q} return all")
          #puts "getting response..."
          resp = @sock.gets
        end
        if (resp.match(/^501:.*/))
          # no matches
          return []
        elsif (resp.match(/^102:.*/))
          # go ahead
          # which of the results are we processing?
          result_num = 1
          # array of records to return
          records = Array.new
          record = Hash.new
          while (@sock.gets.match(/^-200:(\d+):\s*(\w+):\s(.*)$/))
            # $1 => the number person we're processing
            # $2 => the field name
            # $3 => the field contents
            #puts "$1: #$1 $2: #$2 $3: #$3"
            # if we're processing a new record now
            if (result_num.to_s != $1)
              # update the num of the record we're processing
              result_num = $1
              # save the previous record in the array
              records.push record
              # start a new record
              record = Hash.new
            end
            
            # save the field
            record[$2] = $3
            
            # handle the two-line address
            if ($2 == "home_address")
              @sock.gets.match(/-200:\d+:\s*:\s(.*)$/)
              # $1 => field value
              record["home_address_2"] = $1
            end
          end
          records.push record
          return records
        else
          # error
          @sock = TCPSocket.new(@host, @port)
  	      @queries = 0
          query(q)
          #raise "Error talking to PH server"
        end
      }
    end
    
    def Ph.is_student?(record)
      return record["type"] != nil
    end
    
    def Ph.is_facstaff?(record)
      return record["title"] != nil
    end
  end
    
  class UsernameGenerator
    
  end
  class OitUsernameGenerator < UsernameGenerator
    def each
      # new unix id scheme eg abc7
      "aa".upto("zzz") do |initials|
        1.upto(99) do |num|
          yield initials + num.to_s
        end
      end
      
      # old fac/staff unix ids
      "aaa".upto("zzzzzzzz") do |un|
        yield un
        # some have numbers on the end.
        1.upto(9) do |num|
          yield un + num.to_s
        end
      end
      
      # old student unix ids
      "08".upto("10") do |yr|
      "aa".upto("zzz") do |initials|
          yield yr.to_s + initials
          2.upto(9) do |us|
            yield yr + initials + "_" + us.to_s
          end
        end
      end
    end
  end
  
end
