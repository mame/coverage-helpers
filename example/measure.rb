require "coverage"
require "coverage/helpers"
require "optparse"

# setup
output_marshal = "cov.dat"
output_lcov_info = "cov.info"
add = nil
base = nil
o = OptionParser.new
o.on("-o DAT", "output coverage data (in Marshal format)") {|v| output_marshal = v }
o.on("-l LCOVINFO", "output coverage data (in LCOV info format)") {|v| output_lcov_info = v }
o.on("-a DAT", "measure total coverage with this coverage") {|v| add = v }
o.on("-b DAT", "measure diff from this coverage") {|v| base = v }
o.parse!

# measure
Coverage.start(:all)
load ARGV.shift
cov = Coverage.result

# merge
if add
  add = Coverage::Helpers.load(add)
  cov = Coverage::Helpers.sanitize(cov)
  cov = Coverage::Helpers.merge(cov, add)
end

# diff
if base
  base = Coverage::Helpers.load(base)
  cov = Coverage::Helpers.sanitize(cov)
  cov = Coverage::Helpers.diff(cov, base)
end

# save the result in Marshal format
Coverage::Helpers.save(output_marshal, cov)

# save the result in LCOV info format
open(output_lcov_info, "w") do |f|
  Coverage::Helpers.to_lcov_info(cov, out: f)
end
