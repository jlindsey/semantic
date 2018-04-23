class String
  def to_version
    Semantic::Version.new self
  end

  def is_version?
    !Semantic::Version::SemVerRegexp.match(self).nil?
  end
end
