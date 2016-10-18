module WsoTools

  module Net
    def Net.on_campus?(ip)
      (ip =~ /^137\.165\..*\..*/ || ip =~ /^192\.168\.0\..*/) == 0
    end

    def Net.localhost?(ip)
      ip == "127.0.0.1"
    end
  end

  ## Authentication against LDAPs
  module Auth
    #require 'ldap' #FIXME

    def Auth.oit_auth?(unix, password)
      if Rails.env.test? || Rails.env.development?
        return User.where(unix_id: unix).any?
      end

      # return false #unless unix and unix.match(/^\w+$/)
      server = "137.165.4.72" # nds2
      port = 389
      %w{student faculty staff}.any? { |t|
        Auth.ldap_auth?(server, "cn=#{unix},ou=#{t},o=williams", password)
      }
      # Auth.ldap_auth?("nds1.williams.edu", "cn=#{unix},o=williams", password)
    end

    def Auth.alumni_auth?(username, password)
      return false unless username and username.match(/^\w+$/)
      # Auth.ldap_auth?("alumni.williams.edu", "uid=#{username},ou=alumni,o=williams", password)

      # New auth method, 06/2012 -- Chuan Ji
      system('/web/test/tools/alumni_auth.py', username, password)
      return $?.exitstatus == 0
    end


    protected

    def Auth.okay_local?
      x = ENV["LOCAL_WSO"].try(:downcase)
      x == 'true' || x == 't' || x == '1'
    end

    def Auth.ldap_auth?(server, binddn, password, port = 389)
      if password.nil? or password.empty?
        return false
      end
      begin
        conn = LDAP::Conn.new(server, port)
        conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION,3)
        conn.bind(binddn, password) # Try these credentials
      rescue LDAP::ResultError # Invalid credentials
        return false
      ensure
        begin
          conn.unbind unless conn.nil?
        rescue LDAP::InvalidDataError
          # Whatever. Already unbound for some reason.
        end
      end
      return true # Good to go
    end

    """
    def Auth.ldap_auth?(server, binddn, password, port = 389)
      # return false
      if password.nil? or password.empty?
        return false
      end
      begin
        conn = LDAP::Conn.new(server, port)
	conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION,3)
        # return false
        # return conn.simple_bind(binddn, password)
        result = conn.bind(binddn, password)
        if result.nil?
          conn.unbind
          return true
        end
      rescue
      ensure
        conn.unbind unless conn.nil?
      end
      return false
    end
    """

  end

end
