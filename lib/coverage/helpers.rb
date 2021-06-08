require "coverage"

module Coverage
  module Helpers
    VERSION = "1.0.0"

    # helper methods
    using(Module.new { refine(Kernel) do
      def old2new!(cov)
        cov.each do |path, runs|
          cov[path] = { :lines => runs }
        end
      end

      def merge_lines(dst, src)
        dst.concat([nil] * [src.size - dst.size, 0].max)
        src.each_with_index do |run, i|
          next unless run
          dst[i] ||= 0
          dst[i] += run
        end
      end

      def merge_branches(dst, src)
        src.each do |base, targets|
          dst[base] ||= {}
          targets.each do |target, run|
            dst[base][target] ||= 0
            dst[base][target] += run
          end
        end
      end

      def merge_methods(dst, src)
        src.each do |mthd, run|
          dst[mthd] ||= 0
          dst[mthd] += run
        end
      end

      def diff_lines(min, sub)
        min += [nil] * [sub.size - min.size, 0].max
        sub.each_with_index do |run, i|
          next unless run
          min[i] = [min[i] - run, 0].max if min[i]
        end
        min
      end

      def diff_branches(min, sub)
        nruns = {}
        min.each do |base, targets|
          nruns[base] ||= {}
          targets.each do |target, run|
            run2 = sub.dig(base, target) || 0
            nruns[base][target] = [run - run2, 0].max
          end
        end
        nruns
      end

      def diff_methods(min, sub)
        nruns = {}
        min.each do |mthd, run|
          run2 = sub[mthd] || 0
          nruns[mthd] = [run - run2, 0].max
        end
        nruns
      end
    end })

    module_function

    # Sum up all coverage results.
    def self.merge(*covs)
      ncov = {}
      old_format = true

      covs.each do |cov|
        cov.each do |path, runs|
          if runs.is_a?(Array) && old_format
            # merge two old-format (ruby 2.4 or before) coverage results
            merge_lines(ncov[path] ||= [], runs)
            next
          end

          # promotes from old format to new one
          if runs.is_a?(Array)
            runs = { :lines => runs }
          end
          if old_format
            old_format = false
            old2new!(ncov)
          end

          # merge two new-format (ruby 2.5 or later) coverage results
          ncov[path] ||= {}
          [
            [:lines, :merge_lines, []],
            [:branches, :merge_branches, {}],
            [:methods, :merge_methods, {}],
          ].each do |type, merge_func, default|
            if runs[type]
              send(merge_func, ncov[path][type] ||= default, runs[type])
            end
          end
        end
      end

      ncov
    end

    # Extract the coverage results that is covered by `cov1` but not covered by `cov2`.
    def diff(cov1, cov2)
      ncov = {}
      old_format = true

      cov1.each do |path1, runs1|
        if cov2[path1]
          runs2 = cov2[path1]

          if runs1.is_a?(Array) && runs2.is_a?(Array) && old_format
            # diff two old-format (ruby 2.4 or before) coverage results
            ncov[path1] = diff_lines(runs1, runs2)
            next
          end

          # promotes from old format to new one
          if runs1.is_a?(Array)
            runs1 = { :lines => runs1 }
          end
          if runs2.is_a?(Array)
            runs2 = { :lines => runs2 }
          end
          if old_format
            old_format = false
            old2new!(ncov)
          end

          # diff two new-format (ruby 2.5 or later) coverage results
          ncov[path1] = {}
          [
            [:lines, :diff_lines],
            [:branches, :diff_branches],
            [:methods, :diff_methods],
          ].each do |type, diff_func|
            if runs1[type]
              if runs2[type]
                ncov[path1][type] = send(diff_func, runs1[type], runs2[type])
              else
                ncov[path1][type] = runs1[type]
              end
            end
          end
        else
          if runs1.is_a?(Array) && old_format
            ncov[path1] = runs1
            next
          end

          # promotes from old format to new one
          if runs1.is_a?(Array)
            runs1 = { :lines => runs1 }
          end
          if old_format
            old_format = false
            old2new!(ncov)
          end
          ncov[path1] = runs1
        end
      end

      ncov
    end

    # Make the coverage result able to marshal.
    def sanitize(cov)
      ncov = {}
      cov.each do |path, runs|
        if runs.is_a?(Array)
          ncov[path] = runs
          next
        end

        ncov[path] = {}
        ncov[path][:lines] = runs[:lines] if runs[:lines]
        ncov[path][:branches] = runs[:branches] if runs[:branches]

        if runs[:methods]
          ncov[path][:methods] = methods = {}
          runs[:methods].each do |mthd, run|
            klass =
              begin
                Marshal.dump(mthd[0])
                mthd[0]
              rescue
                mthd[0].to_s
              end
            methods[[klass] + mthd.drop(1)] = run
          end
        end
      end
      ncov
    end

    # Save the coverage result to a file.
    def save(path, cov)
      File.binwrite(path, Marshal.dump(sanitize(cov)))
    end

    # Load the coverage result from a file.
    def load(path)
      Marshal.load(File.binread(path))
    end

    # Translate the result into LCOV info format.
    def to_lcov_info(cov, out: "", test_name: nil)
      out << "TN:#{ test_name }\n"
      cov.each do |path, runs|
        out << "SF:#{ path }\n"

        # function coverage
        if runs.is_a?(Hash) && runs[:methods]
          total = covered = 0
          runs[:methods].each do |(klass, name, lineno), run|
            out << "FN:#{ lineno },#{ klass }##{ name }\n"
            total += 1
            covered += 1 if run > 0
          end
          out << "FNF:#{ total }\n"
          out << "FNF:#{ covered }\n"
          runs[:methods].each do |(klass, name, _), run|
            out << "FNDA:#{ run },#{ klass }##{ name }\n"
          end
        end

        # line coverage
        if runs.is_a?(Array) || (runs.is_a?(Hash) && runs[:lines])
          total = covered = 0
          lines = runs.is_a?(Array) ? runs : runs[:lines]
          lines.each_with_index do |run, lineno|
            next unless run
            out << "DA:#{ lineno + 1 },#{ run }\n"
            total += 1
            covered += 1 if run > 0
          end
          out << "LF:#{ total }\n"
          out << "LH:#{ covered }\n"
        end

        # branch coverage
        if runs.is_a?(Hash) && runs[:branches]
          total = covered = 0
          id = 0
          runs[:branches].each do |(_base_type, _, base_lineno), targets|
            i = 0
            targets.each do |(_target_type, _target_lineno), run|
              out << "BRDA:#{ base_lineno },#{ id },#{ i },#{ run }\n"
              total += 1
              covered += 1 if run > 0
              i += 1
            end
            id += 1
          end
          out << "BRF:#{ total }\n"
          out << "BRH:#{ covered }\n"
        end

        out << "end_of_record\n"
      end

      out
    end
  end
end
