# See: http://semver.org
module Semantic
  class Version
    SemVerRegexp = /\A(\d+\.\d+\.\d+)(-([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?(\+([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?\Z/
    attr_accessor :major, :minor, :patch, :pre, :build

    def initialize version_str
      raise ArgumentError.new("#{version_str} is not a valid SemVer Version (http://semver.org)") unless version_str =~ SemVerRegexp

      version, parts = version_str.split '-'
      if not parts.nil? and parts.include? '+'
        @pre, @build = parts.split '+'
      elsif version.include? '+'
        version, @build = version.split '+'
      else
        @pre = parts
      end


      @major, @minor, @patch = version.split('.').map(&:to_i)
    end

    def to_a
      [@major, @minor, @patch, @pre, @build]
    end

    def to_s
      str = [@major, @minor, @patch].join '.'
      str << '-' << @pre unless @pre.nil?
      str << '+' << @build unless @build.nil?

      str
    end

    def to_h
      keys = [:major, :minor, :patch, :pre, :build]
      Hash[keys.zip(self.to_a)]
    end

    alias to_hash to_h
    alias to_array to_a
    alias to_string to_s

    def <=> other_version
      other_version = Version.new(other_version) if other_version.is_a? String

      v1 = self.dup
      v2 = other_version.dup

      # The build must be excluded from the comparison, so that e.g. 1.2.3+foo and 1.2.3+bar are semantically equal.
      # "Build metadata SHOULD be ignored when determining version precedence".
      # (SemVer 2.0.0-rc.2, paragraph 10 - http://www.semver.org)
      v1.build = nil
      v2.build = nil

      compare_recursively(v1.to_a, v2.to_a)
    end

    def > other_version
      (self <=> other_version) == 1
    end

    def < other_version
      (self <=> other_version) == -1
    end

    def >= other_version
      (self <=> other_version) >= 0
    end

    def <= other_version
      (self <=> other_version) <= 0
    end

    def == other_version
      (self <=> other_version) == 0
    end

    def satisfies other_version
      return true if other_version.strip == '*'
      parts = other_version.split(/(\d(.+)?)/, 2)
      comparator, other_version_string = parts[0].strip, parts[1].strip

      begin
        Version.new other_version_string
        comparator.empty? && comparator = '=='
        satisfies_comparator? comparator, other_version_string
      rescue ArgumentError
        if ['<', '>', '<=', '>='].include?(comparator)
          satisfies_comparator? comparator, pad_version_string(other_version_string)
        else
          tilde_matches? other_version_string
        end
      end
    end

    [:major, :minor, :patch].each do |term|
      define_method("#{term}!") { increment!(term) }
    end

    def increment!(term)
      new_version = clone
      new_value = send(term) + 1

      new_version.send("#{term}=", new_value)
      new_version.minor = 0 if term == :major
      new_version.patch = 0 if term == :major || term == :minor
      new_version.build = new_version.pre = nil

      new_version
    end

    private

    def pad_version_string version_string
      parts = version_string.split('.').reject {|x| x == '*'}
      while parts.length < 3
        parts << '0'
      end
      parts.join '.'
    end

    def tilde_matches? other_version_string
      this_parts = to_a.collect(&:to_s)
      other_parts = other_version_string.split('.').reject {|x| x == '*'}
      other_parts == this_parts[0..other_parts.length-1]
    end

    def satisfies_comparator? comparator, other_version_string
      if comparator == '~'
        tilde_matches? other_version_string
      else
        self.send comparator, other_version_string
      end
    end

    def compare_recursively ary1, ary2
      # Short-circuit the recursion entirely if they're just equal
      return 0 if ary1 == ary2

      a = ary1.shift; b = ary2.shift

      # Reached the end of the arrays, equal all the way down
      return 0 if a.nil? and b.nil?

      # Mismatched types (ie. one has a pre and the other doesn't)
      if a.nil? and not b.nil?
        return 1
      elsif not a.nil? and b.nil?
        return -1
      end

      if a < b
        return -1
      elsif a > b
        return 1
      end

      # Versions are equal thus far, so recurse down to the next part.
      compare_recursively ary1, ary2
    end
  end
end
