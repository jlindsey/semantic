# See: http://semver.org
class Semantic::Version
  SemVerRegexp = /^(\d+\.\d+\.\d+)(-([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?(\+([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?$/
  attr_accessor :major, :minor, :patch, :pre, :build

  def initialize version_str
    raise ArgumentError.new("Not a valid SemVer Version (http://semver.org)") unless version_str =~ SemVerRegexp

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
    compare_recursively self.to_a.dup, other_version.to_a.dup
  end

  def > other_version
    if (self <=> other_version) == 1 then true else false end
  end

  def < other_version
    if (self <=> other_version) == -1 then true else false end
  end

  def >= other_version
    if (self <=> other_version) >= 0 then true else false end
  end

  def <= other_version
    if (self <=> other_version) <= 0 then true else false end
  end

  def == other_version
    if (self <=> other_version) == 0 then true else false end
  end

  private

  def compare_recursively ary1, ary2
    # Short-circuit the recursion entirely if they're just equal
    return 0 if ary1 == ary2

    a = ary1.shift; b = ary2.shift

    # Reached the end of the arrays, equal all the way down
    return 0 if a.nil? and b.nil?

    # Mismatched types (ie. one has a build and the other doesn't)
    if a.nil? and not b.nil?
      return -1
    elsif not a.nil? and b.nil?
      return 1
    end

    # Less or greater than
    if a > b
      return 1
    elsif a < b
      return -1
    end

    # Recurse down to the next part if equal
    compare_recursively ary1, ary2
  end
end

