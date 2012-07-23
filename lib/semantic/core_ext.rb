class String
  def to_version
    Semantic::Version.new self
  end
end
