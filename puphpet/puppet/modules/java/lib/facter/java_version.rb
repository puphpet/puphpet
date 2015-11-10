# Fact: java_version
#
# Purpose: get full java version string
#
# Resolution:
#   Tests for presence of java, returns nil if not present
#   returns output of "java -version" and splits on \n + '"'
#
# Caveats:
#   none
#
# Notes:
#   None
if Facter::Util::Resolution.which('java')
  Facter.add(:java_version) do
    setcode do
      Facter::Util::Resolution.exec('java -version 2>&1').lines.first.split(/"/)[1].strip
    end
  end
end
