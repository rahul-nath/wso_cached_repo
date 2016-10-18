module Search
  require 'strscan'
  
  class Query
    attr_reader :query
    
    # don't allow OR for or. If you want to search for Oregon, you're screwed...
    def initialize(query="")
      @symbols = {
        :begin => %r/\(\s*(?=[^\s\)&,\|])/,
        :end => %r/\s*\)(?=[^\w]|\Z)/,
        :and => %r/(?:\s+|\s*&{1,2}\s*)(?=[\w\("])/,
        :or => %r/\s*(?:,|\|{1,2})\s*(?=[\w\("])/,
        :label => %r/(\w+(?:-\w+)?):\s*(?=[\w\("])/,
        # :not => %r/!\s*(?=[\w\("])/, # NOT is VERY HARD
        :word => %r/([\w\-]+(?:'[\w\-]+)?)(?=[^:\w\-\(]|\Z)/,
        :quoted => %r/"([^"]+)"/
      }
      @query = query
    end
    
    def results
      if @results
        @results
      else
        @results = collect_results(StringScanner.new(@query))
      end
    end
    
    def to_s
      @query
    end
    
    def source
      @query
    end
    
    def &(other_query)
      q = self.new("(#{@query}) & (#{other_query.query})")
      q.results= results & other_query.results
      q
    end
    
    def |(other_query)
      q = self.new("(#{@query}) | (#{other_query.query})")
      q.results= results | other_query.results
      q
    end
    
    def and_with!(other_query)
      @query = "(#{@query}) & (#{other_query.query})"
    end
    
    def or_with!(other_query)
      @query = "#{@query} | #{other_query.query}"
    end
    
    def empty?
      @query.empty?
    end
    
    protected
    
    def results=(res)
      @results = res
    end
    
    ## Redefine this in subclasses
    def get_word_results(word, label=nil)
      return [word]
    end
    
    private
    
    def collect_results(q_scanner, label=nil, paren=false)
      open_paren_pos = q_scanner.pos
      if q_scanner.matched?
        open_paren_pos -= q_scanner.matched_size
      end
      results = Array.new
      and_results = nil
      last_label = label
      until q_scanner.eos?
        if q_scanner.scan( @symbols[:end] )
          # END paren block: return unless we shouldn't have one
          if paren
            if and_results
              return results | and_results
            else
              return results
            end
          else
            raise QuerySyntaxError.new("Unmatched parenthesis.", @query.clone, q_scanner.pos - 1, 1)
          end
        elsif q_scanner.scan( @symbols[:begin] )
          # BEGIN paren block: recursive step
          if and_results
            and_results &= collect_results(q_scanner, last_label, true)
          else
            and_results = collect_results(q_scanner, last_label, true)
          end
          # we "used" the label here, so reset it
          last_label = label
        elsif q_scanner.scan( @symbols[:and] )
          # AND: nothin' special
        elsif q_scanner.scan( @symbols[:or] )
          # OR: throw and_results into results and get new and_results
          if and_results
            results |= and_results
            and_results = nil
          end
          #elsif q_scanner.scan( @symbols[:not] )
          # THIS IS HARD
        elsif q_scanner.scan( @symbols[:label] )
          # LABEL: if we've already got one, this is a syntax error
          # otherwise, set last_label
          new_label = q_scanner[1]
          last_label ||= label
          if last_label
            q_scanner.unscan
            raise QuerySyntaxError.new("Nested labels: \"#{last_label}\" and \"#{new_label}\". Add a word or parenthesized block after \"#{last_label}\" or check your parentheses.", @query.clone, @query[0..q_scanner.pos].rindex(last_label), last_label.length + 1, q_scanner.pos, new_label.length + 1)
          else
            last_label = new_label
          end
        elsif q_scanner.scan( @symbols[:word] ) or q_scanner.scan( @symbols[:quoted] )
          # WORD: call the block on it (with last_label)
          # then reset last_label to label
          word = q_scanner[1]
          begin
            if and_results
              and_results &= get_word_results word, last_label
            else
              and_results = get_word_results word, last_label
            end
          rescue InvalidLabelError => e
            raise QuerySyntaxError.new(e.message, @query.clone, @query.index("#{e.label}:"), e.label.length + 1)
          end
          # we've "used" the label. If it's for this entire block,
          # keep it, else set to nil if local. The following line
          # accomplishes this nicely.
          last_label = label
        else
          # BAD SYNTAX: raise a nice exception
          q_scanner.scan( /\s*(?=\S)/ )
          pos = q_scanner.pos
          if q_scanner.scan( /(\(|,|\|{1,2}|&{1,2})\s*(\S?)/ )
            raise QuerySyntaxError.new("Missing term: Add a word or parenthesized block between \"#{q_scanner[1]}\" and \"#{q_scanner[2]}\".", 
              @query.clone, q_scanner.pos - q_scanner[2].length, q_scanner[2].length)
          elsif q_scanner.scan( /(\w+(?:-\w+)?:)\s*(\S?|\Z)/ )
            raise QuerySyntaxError.new("Dangling label: Add a word or parenthesized block between the label \"#{q_scanner[1]}\" and \"#{q_scanner[2]}\".", 
              @query.clone, pos, q_scanner[1].length, q_scanner.pos - q_scanner[2].length, q_scanner[2].length)
          elsif q_scanner.scan( /([\w\-]+(?:'[\w\-]+)?)(\()|(\))([\w\-]+(?:'[\w\-]+)?)/ )
            # needs space before open paren
            raise QuerySyntaxError.new("Missing operator: Add a space, \"&\", \",\", or \"|\" between \"#{q_scanner[1] or q_scanner[3]}\" and \"#{q_scanner[2] or q_scanner[4]}\".", 
              @query.clone, pos, q_scanner.matched_size)
          else
            # if it's a quote, then say it's unmatched, otherwise, illegal character.
            raise QuerySyntaxError.new("Illegal character: \"#{q_scanner.peek(1)}\".", @query.clone, q_scanner.pos, 1)
          end
        end
      end
      if paren
        raise QuerySyntaxError.new("Unmatched parenthesis.", @query.clone, open_paren_pos, 1)
      end
      if and_results
        results | and_results
      else
        results
      end
    end
    
  end
  
  class QuerySyntaxError < RuntimeError
    def initialize(message, source="", index_1=0, length_1=0, index_2 = nil, length_2 = nil)
      super(message)
      @source = source
      @index_1 = index_1
      @index_2 = index_2
      @length_1 = length_1
      @length_2 = length_2
    end
    
    # takes a block which does any formatting desired...
    def show_error
      yield(@source, @index_1, @length_1, @index_2, @length_2)
    end
  end
  
  class FacebookQuery < Query
    protected
    def get_word_results(word, label=nil)
      if label
        field = field_name(label)
        if field == "building"
          users = Staff.joins(:office).merge(Office.where("lower(number) LIKE ?", "%#{word.downcase}%")) |
            Professor.joins(:office).merge(Office.where("lower(number) LIKE ?", "%#{word.downcase}%"))
        elsif field == "dorm"
          dorm = Dorm.where("lower(name) LIKE ?", "%#{word.downcase}%").first
          users = dorm ? dorm.students.where(dorm_visible: true) : []     
        elsif field == "room"
          users = Student.where(dorm_visible: true).joins(:dorm_room).merge(DormRoom.where("lower(number) LIKE ?", "%#{word.downcase}%"))
        elsif ["department", "dept"].include?(field)
          department = (Department.where("lower(name) = ?", word.downcase) || Department.where("lower(abbrev) = ?", word.downcase)).first
          return [] unless department
          users = department.users
        elsif field == "neighborhood"
          neighborhood = Neighborhood.where("lower(name) = ?", word.downcase).first
          return [] unless Neighborhood
          users = neighborhood.students.where(dorm_visible: true)
        else
          users = User.where("lower(#{field}) LIKE ?", "%#{word.downcase}%")
          users = users.where(home_visible: true) if field.include?("home")
        end
        return users.find_all { |u| u.at_williams? && u.visible?}
      end
      users = User.where("lower(search_fields) LIKE ? ", "%#{word}%")
      ## This allows us to have "other" users (alums) that don't show up in/can't see the facebook.
      return users.select { |u| u.at_williams? && u.visible? }
    end
    
    def field_name(string)
      case string.downcase
      when "name"
        "name"
      when "class"
        "class_year"
      when "year"
        "class_year"
      when "neighborhood"
        "neighborhood"
      when "cluster"
        "neighborhood"
      when "room"
        "room"
      when "entry"
        "entry"  
      when "dorm"
        "dorm"
      when "building"
        "building"
      when "bldg"
        "building"
      when "unix"
        "unix_id"
      when "email"
        "williams_email"
      when "title"
        "title"
      when "department"
        "department"
      when "dept"
        "department"
      when "major"
        "major"
      when "zip"
        "home_zip"
      when "city"
        "home_town"
      when "town"
        "home_town"
      when "state"
        "home_state"
      when "country"
        "home_country"
      when "phone"
        "campus_phone_ext"
      when "ext"
        "campus_phone_ext"
      else
        raise InvalidLabelError.new(string)
      end
    end
    
  end
  
  class InvalidLabelError < RuntimeError
    attr_reader :label
    def initialize(label)
      super("Invalid label: The label \"#{label}\" does not exist.")
      @label = label
    end
    
  end
  
end