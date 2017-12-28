def foo(n)
  if n == 0
    :zero
  else
    :non_zero
  end
end

def bar
  :bar
end

def baz
  raise
end

case ARGV[0]
when "1"
  foo(0)
when "2"
  bar
end
