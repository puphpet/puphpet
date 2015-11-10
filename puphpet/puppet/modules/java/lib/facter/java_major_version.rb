# Fact: java_major_version
#
# Purpose: get Java's major version
#
# Resolution:
#   Tests for presence of java, returns nil if not present
#   returns output of "java -version" and splits on \n + '"'
#   eg.
#
# Caveats:
#   none
#
# Notes:
#   None
Facter.add(:java_major_version) do
  setcode do
    java_version = Facter.value(:java_version)
    java_patch_level = java_version.strip.split('_')[0].split('.')[1] unless java_version.nil?
  end
end