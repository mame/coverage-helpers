require "test_helper"

class Coverage::HelpersTest < Minitest::Test
  def test_merge_lines
    cov1 = {
      "foo.rb" => { :lines => [1, 1, 0, nil], },
      "bar.rb" => { :lines => [1] }
    }
    cov2 = {
      "foo.rb" => { :lines => [1, 0, 1, nil], },
      "baz.rb" => { :lines => [0] }
    }
    exp = {
      "foo.rb" => { :lines => [2, 1, 1, nil] },
      "bar.rb" => { :lines => [1] },
      "baz.rb" => { :lines => [0] },
    }

    assert_equal exp, Coverage::Helpers.merge(cov1, cov2)
  end

  def test_merge_branches
    cov1 = {
      "foo.rb" => { :branches => {
        [:if, 0, 1,0, 5,3] => {
          [:then, 1, 2,2, 2,5] => 0,
          [:else, 1, 4,2, 4,5] => 1,
        }
      } },
      "bar.rb" => { :branches => {
        [:if, 0, 1,0, 5,3] => {
          [:then, 1, 2,2, 2,5] => 1,
          [:else, 1, 4,2, 4,5] => 0,
        }
      } },
    }
    cov2 = {
      "foo.rb" => { :branches => {
        [:if, 0, 1,0, 5,3] => {
          [:then, 1, 2,2, 2,5] => 1,
          [:else, 1, 4,2, 4,5] => 0,
        }
      } },
      "baz.rb" => { :branches => {
        [:if, 0, 1,0, 5,3] => {
          [:then, 1, 2,2, 2,5] => 0,
          [:else, 1, 4,2, 4,5] => 1,
        }
      } },
    }
    exp = {
      "foo.rb" => { :branches => {
        [:if, 0, 1,0, 5,3] => {
          [:then, 1, 2,2, 2,5] => 1,
          [:else, 1, 4,2, 4,5] => 1,
        }
      } },
      "bar.rb" => { :branches => {
        [:if, 0, 1,0, 5,3] => {
          [:then, 1, 2,2, 2,5] => 1,
          [:else, 1, 4,2, 4,5] => 0,
        }
      } },
      "baz.rb" => { :branches => {
        [:if, 0, 1,0, 5,3] => {
          [:then, 1, 2,2, 2,5] => 0,
          [:else, 1, 4,2, 4,5] => 1,
        }
      } },
    }

    assert_equal exp, Coverage::Helpers.merge(cov1, cov2)
  end

  def test_merge_methods
    cov1 = {
      "foo.rb" => { :methods => {
        [Object, :foo1, 0, 1,0, 2,3] => 1,
        [Object, :foo2, 0, 4,0, 5,3] => 0,
        [Object, :foo3, 0, 7,0, 8,3] => 1,
      } },
      "bar.rb" => { :methods => {
        [Object, :bar1, 0, 1,0, 2,3] => 1,
        [Object, :bar2, 0, 4,0, 5,3] => 0,
      } },
    }
    cov2 = {
      "foo.rb" => { :methods => {
        [Object, :foo1, 0, 1,0, 2,3] => 1,
        [Object, :foo2, 0, 4,0, 5,3] => 1,
        [Object, :foo3, 0, 7,0, 8,3] => 0,
      } },
      "baz.rb" => { :methods => {
        [Object, :bar1, 0, 1,0, 2,3] => 0,
        [Object, :bar2, 0, 4,0, 5,3] => 1,
      } },
    }
    exp = {
      "foo.rb" => { :methods => {
        [Object, :foo1, 0, 1,0, 2,3] => 2,
        [Object, :foo2, 0, 4,0, 5,3] => 1,
        [Object, :foo3, 0, 7,0, 8,3] => 1,
      } },
      "bar.rb" => { :methods => {
        [Object, :bar1, 0, 1,0, 2,3] => 1,
        [Object, :bar2, 0, 4,0, 5,3] => 0,
      } },
      "baz.rb" => { :methods => {
        [Object, :bar1, 0, 1,0, 2,3] => 0,
        [Object, :bar2, 0, 4,0, 5,3] => 1,
      } },
    }

    assert_equal exp, Coverage::Helpers.merge(cov1, cov2)
  end

  def test_merge_three_results
    cov1 = {
      "foo.rb" => { :lines => [1, 1, 0, nil], },
      "bar.rb" => { :lines => [1] }
    }
    cov2 = {
      "foo.rb" => { :lines => [1, 0, 1, nil], },
      "baz.rb" => { :lines => [0] }
    }
    cov3 = {
      "foo.rb" => { :lines => [1, 1, 1, nil], },
      "qux.rb" => { :lines => [2] }
    }
    exp = {
      "foo.rb" => { :lines => [3, 2, 2, nil] },
      "bar.rb" => { :lines => [1] },
      "baz.rb" => { :lines => [0] },
      "qux.rb" => { :lines => [2] },
    }

    assert_equal exp, Coverage::Helpers.merge(cov1, cov2, cov3)
  end

  def test_merge_old_format
    cov1 = { "foo.rb" => [1, 1, 0, nil], "bar.rb" => [1] }
    cov2 = { "foo.rb" => [1, 0, 1, nil], "baz.rb" => [0] }
    exp = {
      "foo.rb" => [2, 1, 1, nil],
      "bar.rb" => [1],
      "baz.rb" => [0],
    }

    assert_equal exp, Coverage::Helpers.merge(cov1, cov2)
  end

  def test_merge_new_and_old_format
    cov1 = {
      "foo.rb" => { :lines => [1, 1, 0, nil], },
      "bar.rb" => { :lines => [1] }
    }
    cov2 = { "foo.rb" => [1, 0, 1, nil], "baz.rb" => [0] }
    exp = {
      "foo.rb" => { :lines => [2, 1, 1, nil] },
      "bar.rb" => { :lines => [1] },
      "baz.rb" => { :lines => [0] },
    }

    assert_equal exp, Coverage::Helpers.merge(cov1, cov2)
  end

  def test_merge_old_and_new_format
    cov1 = { "foo.rb" => [1, 1, 0, nil], "bar.rb" => [1] }
    cov2 = {
      "foo.rb" => { :lines => [1, 0, 1, nil], },
      "baz.rb" => { :lines => [0] }
    }
    exp = {
      "foo.rb" => { :lines => [2, 1, 1, nil] },
      "bar.rb" => { :lines => [1] },
      "baz.rb" => { :lines => [0] },
    }

    assert_equal exp, Coverage::Helpers.merge(cov1, cov2)
  end


  def test_diff_lines
    cov1 = {
      "foo.rb" => { :lines => [1, 1, 0, nil], },
      "bar.rb" => { :lines => [1] }
    }
    cov2 = {
      "foo.rb" => { :lines => [1, 0, 1, nil], },
      "baz.rb" => { :lines => [0] }
    }
    exp = {
      "foo.rb" => { :lines => [0, 1, 0, nil] },
      "bar.rb" => { :lines => [1] },
    }

    assert_equal exp, Coverage::Helpers.diff(cov1, cov2)
  end

  def test_diff_branches
    cov1 = {
      "foo.rb" => { :branches => {
        [:if, 0, 1,0, 5,3] => {
          [:then, 1, 2,2, 2,5] => 0,
          [:else, 1, 4,2, 4,5] => 1,
        }
      } },
      "bar.rb" => { :branches => {
        [:if, 0, 1,0, 5,3] => {
          [:then, 1, 2,2, 2,5] => 1,
          [:else, 1, 4,2, 4,5] => 0,
        }
      } },
    }
    cov2 = {
      "foo.rb" => { :branches => {
        [:if, 0, 1,0, 5,3] => {
          [:then, 1, 2,2, 2,5] => 1,
          [:else, 1, 4,2, 4,5] => 0,
        }
      } },
      "baz.rb" => { :branches => {
        [:if, 0, 1,0, 5,3] => {
          [:then, 1, 2,2, 2,5] => 0,
          [:else, 1, 4,2, 4,5] => 1,
        }
      } },
    }
    exp = {
      "foo.rb" => { :branches => {
        [:if, 0, 1,0, 5,3] => {
          [:then, 1, 2,2, 2,5] => 0,
          [:else, 1, 4,2, 4,5] => 1,
        }
      } },
      "bar.rb" => { :branches => {
        [:if, 0, 1,0, 5,3] => {
          [:then, 1, 2,2, 2,5] => 1,
          [:else, 1, 4,2, 4,5] => 0,
        }
      } },
    }

    assert_equal exp, Coverage::Helpers.diff(cov1, cov2)
  end

  def test_diff_methods
    cov1 = {
      "foo.rb" => { :methods => {
        [Object, :foo1, 0, 1,0, 2,3] => 1,
        [Object, :foo2, 0, 4,0, 5,3] => 0,
        [Object, :foo3, 0, 7,0, 8,3] => 1,
      } },
      "bar.rb" => { :methods => {
        [Object, :bar1, 0, 1,0, 2,3] => 1,
        [Object, :bar2, 0, 4,0, 5,3] => 0,
      } },
    }
    cov2 = {
      "foo.rb" => { :methods => {
        [Object, :foo1, 0, 1,0, 2,3] => 1,
        [Object, :foo2, 0, 4,0, 5,3] => 1,
        [Object, :foo3, 0, 7,0, 8,3] => 0,
      } },
      "baz.rb" => { :methods => {
        [Object, :bar1, 0, 1,0, 2,3] => 0,
        [Object, :bar2, 0, 4,0, 5,3] => 1,
      } },
    }
    exp = {
      "foo.rb" => { :methods => {
        [Object, :foo1, 0, 1,0, 2,3] => 0,
        [Object, :foo2, 0, 4,0, 5,3] => 0,
        [Object, :foo3, 0, 7,0, 8,3] => 1,
      } },
      "bar.rb" => { :methods => {
        [Object, :bar1, 0, 1,0, 2,3] => 1,
        [Object, :bar2, 0, 4,0, 5,3] => 0,
      } },
    }

    assert_equal exp, Coverage::Helpers.diff(cov1, cov2)
  end

  def test_diff_old_format
    cov1 = { "foo.rb" => [1, 1, 0, nil], "bar.rb" => [1] }
    cov2 = { "foo.rb" => [1, 0, 1, nil], "baz.rb" => [0] }
    exp = {
      "foo.rb" => [0, 1, 0, nil],
      "bar.rb" => [1],
    }

    assert_equal exp, Coverage::Helpers.diff(cov1, cov2)
  end

  def test_diff_new_and_old_format
    cov1 = {
      "foo.rb" => { :lines => [1, 1, 0, nil], },
      "bar.rb" => { :lines => [1] }
    }
    cov2 = { "foo.rb" => [1, 0, 1, nil], "baz.rb" => [0] }
    exp = {
      "foo.rb" => { :lines => [0, 1, 0, nil] },
      "bar.rb" => { :lines => [1] },
    }

    assert_equal exp, Coverage::Helpers.diff(cov1, cov2)
  end

  def test_diff_old_and_new_format
    cov1 = { "foo.rb" => [1, 1, 0, nil], "bar.rb" => [1] }
    cov2 = {
      "foo.rb" => { :lines => [1, 0, 1, nil], },
      "baz.rb" => { :lines => [0] }
    }
    exp = {
      "foo.rb" => { :lines => [0, 1, 0, nil] },
      "bar.rb" => { :lines => [1] },
    }

    assert_equal exp, Coverage::Helpers.diff(cov1, cov2)
  end

  Coverage.start(:all)
  SampleFile = File.join(__dir__, "fixture.rb")
  load SampleFile
  CovSample1 = Coverage.peek_result
  Coverage::Fixture.foo(0)
  CovSample2 = Coverage.peek_result
  Coverage::Fixture.bar
  CovSample3 = Coverage.result

  def test_actual_sampled_data
    diff_2_1 = Coverage::Helpers.diff(CovSample2, CovSample1)
    cov2 = Coverage::Helpers.merge(CovSample1, diff_2_1)
    assert_equal CovSample2, cov2

    diff_3_2 = Coverage::Helpers.diff(CovSample3, CovSample2)
    cov3 = Coverage::Helpers.merge(CovSample2, diff_3_2)
    assert_equal CovSample3, cov3

    diff_3_1 = Coverage::Helpers.diff(CovSample3, CovSample1)
    cov3 = Coverage::Helpers.merge(CovSample1, diff_3_1)
    assert_equal CovSample3, cov3
  end

  def test_to_lcov_info_lines
    cov = {
      "foo.rb" => { :lines => [2, 1, 1, nil, 0] },
      "bar.rb" => { :lines => [1] },
      "baz.rb" => { :lines => [0] },
    }
    exp = <<-END
TN:
SF:foo.rb
DA:1,2
DA:2,1
DA:3,1
DA:5,0
LF:4
LH:3
end_of_record
SF:bar.rb
DA:1,1
LF:1
LH:1
end_of_record
SF:baz.rb
DA:1,0
LF:1
LH:0
end_of_record
    END

    assert_equal exp, Coverage::Helpers.to_lcov_info(cov)
  end

  def test_to_lcov_info_branches
    cov = {
      "foo.rb" => { :branches => {
        [:if, 0, 1,0, 5,3] => {
          [:then, 1, 2,2, 2,5] => 1,
          [:else, 1, 4,2, 4,5] => 1,
        }
      } },
      "bar.rb" => { :branches => {
        [:if, 0, 1,0, 5,3] => {
          [:then, 1, 2,2, 2,5] => 1,
          [:else, 1, 4,2, 4,5] => 0,
        }
      } },
      "baz.rb" => { :branches => {
        [:if, 0, 1,0, 5,3] => {
          [:then, 1, 2,2, 2,5] => 0,
          [:else, 1, 4,2, 4,5] => 1,
        }
      } },
    }
    exp = <<-END
TN:
SF:foo.rb
BRDA:1,0,0,1
BRDA:1,0,1,1
BRF:2
BRH:2
end_of_record
SF:bar.rb
BRDA:1,0,0,1
BRDA:1,0,1,0
BRF:2
BRH:1
end_of_record
SF:baz.rb
BRDA:1,0,0,0
BRDA:1,0,1,1
BRF:2
BRH:1
end_of_record
    END

    assert_equal exp, Coverage::Helpers.to_lcov_info(cov)
  end

  def test_to_lcov_info_methods
    cov = {
      "foo.rb" => { :methods => {
        [Object, :foo1, 0, 1,0, 2,3] => 2,
        [Object, :foo2, 0, 4,0, 5,3] => 1,
        [Object, :foo3, 0, 7,0, 8,3] => 1,
      } },
      "bar.rb" => { :methods => {
        [Object, :bar1, 0, 1,0, 2,3] => 1,
        [Object, :bar2, 0, 4,0, 5,3] => 0,
      } },
      "baz.rb" => { :methods => {
        [Object, :bar1, 0, 1,0, 2,3] => 0,
        [Object, :bar2, 0, 4,0, 5,3] => 1,
      } },
    }
    exp = <<-END
TN:
SF:foo.rb
FN:0,Object#foo1
FN:0,Object#foo2
FN:0,Object#foo3
FNF:3
FNF:3
FNDA:2,Object#foo1
FNDA:1,Object#foo2
FNDA:1,Object#foo3
end_of_record
SF:bar.rb
FN:0,Object#bar1
FN:0,Object#bar2
FNF:2
FNF:1
FNDA:1,Object#bar1
FNDA:0,Object#bar2
end_of_record
SF:baz.rb
FN:0,Object#bar1
FN:0,Object#bar2
FNF:2
FNF:1
FNDA:0,Object#bar1
FNDA:1,Object#bar2
end_of_record
    END

    assert_equal exp, Coverage::Helpers.to_lcov_info(cov)
  end

  def test_to_lcov_info_options
    cov = {
      "foo.rb" => { :lines => [0] },
    }
    exp = <<-END
TN:foobarbaz
SF:foo.rb
DA:1,0
LF:1
LH:0
end_of_record
    END

    output = ""
    Coverage::Helpers.to_lcov_info(cov, out: output, test_name: "foobarbaz")
    assert_equal exp, output
  end
end
