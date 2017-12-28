class Coverage::Fixture
  def self.foo(n)
    if n == 0
      :zero
    else
      :non_zero
    end
  end

  def self.bar
    :bar
  end

  def self.baz
    raise
  end
end
