#stdlib

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with stdlib](#setup)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

Adds a standard library of resources for Puppet modules.

##Module Description

This module provides a standard library of resources for the development of Puppet
modules. Puppet modules make heavy use of this standard library. The stdlib module adds the following resources to Puppet:

 * Stages
 * Facts
 * Functions
 * Defined resource types
 * Types
 * Providers

> *Note:* As of version 3.7, Puppet Enterprise no longer includes the stdlib module. If you're running Puppet Enterprise, you should install the most recent release of stdlib for compatibility with Puppet modules.

##Setup

Installing the stdlib module adds the functions, facts, and resources of this standard library to Puppet.

##Usage

After you've installed stdlib, all of its functions, facts, and resources are available for module use or development.

If you want to use a standardized set of run stages for Puppet, `include stdlib` in your manifest.

## Reference

### Classes

#### Public Classes

* `stdlib`: Most of stdlib's features are automatically loaded by Puppet. To use standardized run stages in Puppet, declare this class in your manifest with `include stdlib`.

  When declared, stdlib declares all other classes in the module. The only other class currently included in the module is `stdlib::stages`.

  The stdlib class has no parameters.

#### Private Classes

* `stdlib::stages`: This class manages a standard set of run stages for Puppet. It is managed by the stdlib class and should not be declared independently.

  The `stdlib::stages` class declares various run stages for deploying infrastructure, language runtimes, and application layers. The high level stages are (in order):

  * setup
  * main
  * runtime
  * setup_infra
  * deploy_infra
  * setup_app
  * deploy_app
  * deploy

  Sample usage:

  ```
  node default {
    include stdlib
    class { java: stage => 'runtime' }
  }
  ```

### Resources

* `file_line`: This resource ensures that a given line, including whitespace at the beginning and end, is contained within a file. If the line is not contained in the given file, Puppet will add the line. Multiple resources can be declared to manage multiple lines in the same file. You can also use match to replace existing lines.

  ```
  file_line { 'sudo_rule':
    path => '/etc/sudoers',
    line => '%sudo ALL=(ALL) ALL',
  }
  file_line { 'sudo_rule_nopw':
    path => '/etc/sudoers',
    line => '%sudonopw ALL=(ALL) NOPASSWD: ALL',
  }
  ```

  * `after`: Specify the line after which Puppet will add any new lines. (Existing lines are added in place.) Optional.
  * `ensure`: Ensures whether the resource is present. Valid values are 'present', 'absent'.
 * `line`: The line to be added to the file located by the `path` parameter.
 * `match`: A regular expression to run against existing lines in the file; if a match is found, we replace that line rather than adding a new line. Optional.
 * `multiple`: Determine if match can change multiple lines. Valid values are 'true', 'false'. Optional.
 * `name`: An arbitrary name used as the identity of the resource.
 * `path`: The file in which Puppet will ensure the line specified by the line parameter.

### Functions

* `abs`: Returns the absolute value of a number; for example, '-34.56' becomes '34.56'. Takes a single integer and float value as an argument. *Type*: rvalue

* `any2array`: This converts any object to an array containing that object. Empty argument lists are converted to an empty array. Arrays are left untouched. Hashes are converted to arrays of alternating keys and values. *Type*: rvalue

* `base64`: Converts a string to and from base64 encoding.
Requires an action ('encode', 'decode') and either a plain or base64-encoded
string. *Type*: rvalue

* `basename`: Returns the `basename` of a path (optionally stripping an extension). For example:
  * ('/path/to/a/file.ext') returns 'file.ext'
  * ('relative/path/file.ext') returns 'file.ext'
  * ('/path/to/a/file.ext', '.ext') returns 'file'

  *Type*: rvalue

* `bool2num`: Converts a boolean to a number. Converts values:
  * 'false', 'f', '0', 'n', and 'no' to 0.
  * 'true', 't', '1', 'y', and 'yes' to 1.
  Requires a single boolean or string as an input. *Type*: rvalue

* `capitalize`: Capitalizes the first letter of a string or array of strings.
Requires either a single string or an array as an input. *Type*: rvalue

* `ceiling`: Returns the smallest integer greater than or equal to the argument.
Takes a single numeric value as an argument. *Type*: rvalue

* `chomp`: Removes the record separator from the end of a string or an array of
strings; for example, 'hello\n' becomes 'hello'. Requires a single string or array as an input. *Type*: rvalue

* `chop`: Returns a new string with the last character removed. If the string ends with '\r\n', both characters are removed. Applying `chop` to an empty string returns an empty string. If you want to merely remove record separators, then you should use the `chomp` function. Requires a string or an array of strings as input. *Type*: rvalue

* `concat`: Appends the contents of multiple arrays onto array 1. For example:
  * `concat(['1','2','3'],'4')` results in: ['1','2','3','4'].
  * `concat(['1','2','3'],'4',['5','6','7'])` results in: ['1','2','3','4','5','6','7'].

* `count`: Takes an array as first argument and an optional second argument. Count the number of elements in array that matches second argument. If called with only an array, it counts the number of elements that are **not** nil/undef. *Type*: rvalue

* `defined_with_params`: Takes a resource reference and an optional hash of attributes. Returns 'true' if a resource with the specified attributes has already been added to the catalog. Returns 'false' otherwise.

  ```
  user { 'dan':
    ensure => present,
  }

  if ! defined_with_params(User[dan], {'ensure' => 'present' }) {
    user { 'dan': ensure => present, }
  }
  ```

  *Type*: rvalue

* `delete`: Deletes all instances of a given element from an array, substring from a
string, or key from a hash. For example, `delete(['a','b','c','b'], 'b')` returns ['a','c']; `delete('abracadabra', 'bra')` returns 'acada'. `delete({'a' => 1,'b' => 2,'c' => 3},['b','c'])` returns {'a'=> 1} *Type*: rvalue

* `delete_at`: Deletes a determined indexed value from an array. For example, `delete_at(['a','b','c'], 1)` returns ['a','c']. *Type*: rvalue

* `delete_values`: Deletes all instances of a given value from a hash. For example, `delete_values({'a'=>'A','b'=>'B','c'=>'C','B'=>'D'}, 'B')` returns {'a'=>'A','c'=>'C','B'=>'D'} *Type*: rvalue

* `delete_undef_values`: Deletes all instances of the undef value from an array or hash. For example, `$hash = delete_undef_values({a=>'A', b=>'', c=>undef, d => false})` returns {a => 'A', b => '', d => false}. *Type*: rvalue

* `difference`: Returns the difference between two arrays.
The returned array is a copy of the original array, removing any items that
also appear in the second array. For example, `difference(["a","b","c"],["b","c","d"])` returns ["a"].

* `dirname`: Returns the `dirname` of a path. For example, `dirname('/path/to/a/file.ext')` returns '/path/to/a'.

* `downcase`: Converts the case of a string or of all strings in an array to lowercase. *Type*: rvalue

* `empty`: Returns 'true' if the variable is empty. *Type*: rvalue

* `ensure_packages`: Takes a list of packages and only installs them if they don't already exist. It optionally takes a hash as a second parameter to be passed as the third argument to the `ensure_resource()` function. *Type*: statement

* `ensure_resource`: Takes a resource type, title, and a list of attributes that describe a resource.

  ```
  user { 'dan':
    ensure => present,
  }
  ```

  This example only creates the resource if it does not already exist:

    `ensure_resource('user', 'dan', {'ensure' => 'present' })`

  If the resource already exists, but does not match the specified parameters, this function attempts to recreate the resource, leading to a duplicate resource definition error.

  An array of resources can also be passed in, and each will be created with the type and parameters specified if it doesn't already exist.

  `ensure_resource('user', ['dan','alex'], {'ensure' => 'present'})`

  *Type*: statement

* `flatten`: This function flattens any deeply nested arrays and returns a single flat array as a result. For example, `flatten(['a', ['b', ['c']]])` returns ['a','b','c']. *Type*: rvalue

* `floor`: Returns the largest integer less than or equal to the argument.
Takes a single numeric value as an argument. *Type*: rvalue

* `fqdn_rotate`: Rotates an array a random number of times based on a node's fqdn. *Type*: rvalue

* `get_module_path`: Returns the absolute path of the specified module for the current environment.

  `$module_path = get_module_path('stdlib')`

  *Type*: rvalue

* `getparam`: Takes a resource reference and the name of the parameter and
returns the value of the resource's parameter. For example, the following code returns 'param_value'.

  *Example:*

  ```
  define example_resource($param) {
  }

  example_resource { "example_resource_instance":
    param => "param_value"
  }

  getparam(Example_resource["example_resource_instance"], "param")
  ```

  *Type*: rvalue

* `getvar`: Lookup a variable in a remote namespace.

  For example:

  ```
  $foo = getvar('site::data::foo')
  # Equivalent to $foo = $site::data::foo
  ```

  This is useful if the namespace itself is stored in a string:

  ```
  $datalocation = 'site::data'
  $bar = getvar("${datalocation}::bar")
  # Equivalent to $bar = $site::data::bar
  ```

  *Type*: rvalue

* `grep`: This function searches through an array and returns any elements that match the provided regular expression. For example, `grep(['aaa','bbb','ccc','aaaddd'], 'aaa')` returns ['aaa','aaaddd']. *Type*: rvalue

* `has_interface_with`: Returns boolean based on kind and value:
  * macaddress
  * netmask
  * ipaddress
  * network

  *Examples:*

  ```
  has_interface_with("macaddress", "x:x:x:x:x:x")
  has_interface_with("ipaddress", "127.0.0.1")    => true
  ```

  If no kind is given, then the presence of the interface is checked:

  ```
  has_interface_with("lo")                        => true
  ```

  *Type*: rvalue

* `has_ip_address`: Returns true if the client has the requested IP address on some interface. This function iterates through the `interfaces` fact and checks the `ipaddress_IFACE` facts, performing a simple string comparison. *Type*: rvalue

* `has_ip_network`: Returns true if the client has an IP address within the requested network. This function iterates through the 'interfaces' fact and checks the 'network_IFACE' facts, performing a simple string comparision. *Type*: rvalue

* `has_key`: Determine if a hash has a certain key value.

  *Example*:

  ```
  $my_hash = {'key_one' => 'value_one'}
  if has_key($my_hash, 'key_two') {
    notice('we will not reach here')
  }
  if has_key($my_hash, 'key_one') {
    notice('this will be printed')
  }
  ```

  *Type*: rvalue

* `hash`: This function converts an array into a hash. For example, `hash(['a',1,'b',2,'c',3])` returns {'a'=>1,'b'=>2,'c'=>3}. *Type*: rvalue

* `intersection`: This function returns an array an intersection of two. For example, `intersection(["a","b","c"],["b","c","d"])` returns ["b","c"].

* `is_array`: Returns 'true' if the variable passed to this function is an array. *Type*: rvalue

* `is_bool`: Returns 'true' if the variable passed to this function is a boolean. *Type*: rvalue

* `is_domain_name`: Returns 'true' if the string passed to this function is a syntactically correct domain name. *Type*: rvalue

* `is_float`: Returns 'true' if the variable passed to this function is a float. *Type*: rvalue

* `is_function_available`: This function accepts a string as an argument and determines whether the Puppet runtime has access to a function by that name. It returns 'true' if the function exists, 'false' if not. *Type*: rvalue

* `is_hash`: Returns 'true' if the variable passed to this function is a hash. *Type*: rvalue

* `is_integer`: Returns 'true' if the variable returned to this string is an integer. *Type*: rvalue

* `is_ip_address`: Returns 'true' if the string passed to this function is a valid IP address. *Type*: rvalue

* `is_mac_address`: Returns 'true' if the string passed to this function is a valid MAC address. *Type*: rvalue

* `is_numeric`: Returns 'true' if the variable passed to this function is a number. *Type*: rvalue

* `is_string`: Returns 'true' if the variable passed to this function is a string. *Type*: rvalue

* `join`: This function joins an array into a string using a separator. For example, `join(['a','b','c'], ",")` results in: "a,b,c". *Type*: rvalue

* `join_keys_to_values`: This function joins each key of a hash to that key's corresponding value with a separator. Keys and values are cast to strings. The return value is an array in which each element is one joined key/value pair. For example, `join_keys_to_values({'a'=>1,'b'=>2}, " is ")` results in ["a is 1","b is 2"]. *Type*: rvalue

* `keys`: Returns the keys of a hash as an array. *Type*: rvalue

* `loadyaml`: Load a YAML file containing an array, string, or hash, and return the data in the corresponding native data type. For example:

  ```
  $myhash = loadyaml('/etc/puppet/data/myhash.yaml')
  ```

  *Type*: rvalue

* `lstrip`: Strips leading spaces to the left of a string. *Type*: rvalue

* `max`: Returns the highest value of all arguments. Requires at least one argument. *Type*: rvalue

* `member`: This function determines if a variable is a member of an array. The variable can be either a string, array, or fixnum. For example, `member(['a','b'], 'b')` and `member(['a','b','c'], ['b','c'])` return 'true', while `member(['a','b'], 'c')`  and `member(['a','b','c'], ['c','d'])` return 'false'. *Type*: rvalue

* `merge`: Merges two or more hashes together and returns the resulting hash.

  *Example*:

  ```
  $hash1 = {'one' => 1, 'two' => 2}
  $hash2 = {'two' => 'dos', 'three' => 'tres'}
  $merged_hash = merge($hash1, $hash2)
  # The resulting hash is equivalent to:
  # $merged_hash =  {'one' => 1, 'two' => 'dos', 'three' => 'tres'}
  ```

  When there is a duplicate key, the key in the rightmost hash "wins." *Type*: rvalue

* `min`: Returns the lowest value of all arguments. Requires at least one argument. *Type*: rvalue

* `num2bool`: This function converts a number or a string representation of a number into a true boolean. Zero or anything non-numeric becomes 'false'. Numbers greater than 0 become 'true'. *Type*: rvalue

* `parsejson`: This function accepts JSON as a string and converts into the correct Puppet structure. *Type*: rvalue

* `parseyaml`: This function accepts YAML as a string and converts it into the correct Puppet structure. *Type*: rvalue

* `pick`: From a list of values, returns the first value that is not undefined or an empty string. Takes any number of arguments, and raises an error if all values are undefined or empty.

  ```
  $real_jenkins_version = pick($::jenkins_version, '1.449')
  ```

 *Type*: rvalue

* `prefix`: This function applies a prefix to all elements in an array or to the keys in a hash. For example, `prefix(['a','b','c'], 'p')` returns ['pa','pb','pc'], and `prefix({'a'=>'b','b'=>'c','c'=>'d'}, 'p')` returns {'pa'=>'b','pb'=>'c','pc'=>'d'}. *Type*: rvalue


* `assert_private`: This function sets the current class or definition as private.
Calling the class or definition from outside the current module will fail. For example, `assert_private()` called in class `foo::bar` outputs the following message if class is called from outside module `foo`:

  ```
  Class foo::bar is private
  ```

  You can specify the error message you want to use:

  ```
  assert_private("You're not supposed to do that!")
  ```

  *Type*: statement

* `range`: When given range in the form of '(start, stop)', `range` extrapolates a range as an array. For example, `range("0", "9")` returns [0,1,2,3,4,5,6,7,8,9]. Zero-padded strings are converted to integers automatically, so `range("00", "09")` returns [0,1,2,3,4,5,6,7,8,9].

  Non-integer strings are accepted; `range("a", "c")` returns ["a","b","c"], and `range("host01", "host10")` returns ["host01", "host02", ..., "host09", "host10"].

  Passing a third argument will cause the generated range to step by that interval, e.g. `range("0", "9", "2")` returns ["0","2","4","6","8"]

  *Type*: rvalue

* `reject`: This function searches through an array and rejects all elements that match the provided regular expression. For example, `reject(['aaa','bbb','ccc','aaaddd'], 'aaa')` returns ['bbb','ccc']. *Type*: rvalue

* `reverse`: Reverses the order of a string or array. *Type*: rvalue

* `rstrip`: Strips leading spaces to the right of the string.*Type*: rvalue

* `shuffle`: Randomizes the order of a string or array elements. *Type*: rvalue

* `size`: Returns the number of elements in a string or array. *Type*: rvalue

* `sort`: Sorts strings and arrays lexically. *Type*: rvalue

* `squeeze`: Returns a new string where runs of the same character that occur in this set are replaced by a single character. *Type*: rvalue

* `str2bool`: This converts a string to a boolean. This attempts to convert strings that contain values such as '1', 't', 'y', and 'yes' to 'true' and strings that contain values such as '0', 'f', 'n', and 'no' to 'false'. *Type*: rvalue

* `str2saltedsha512`: This converts a string to a salted-SHA512 password hash, used for OS X versions >= 10.7. Given any string, this function returns a hex version of a salted-SHA512 password hash, which can be inserted into your Puppet
manifests as a valid password attribute. *Type*: rvalue

* `strftime`: This function returns formatted time. For example,  `strftime("%s")` returns the time since epoch, and `strftime("%Y=%m-%d")` returns the date. *Type*: rvalue

  *Format:*

    * `%a`: The abbreviated weekday name ('Sun')
    * `%A`: The  full  weekday  name ('Sunday')
    * `%b`: The abbreviated month name ('Jan')
    * `%B`: The  full  month  name ('January')
    * `%c`: The preferred local date and time representation
    * `%C`: Century (20 in 2009)
    * `%d`: Day of the month (01..31)
    * `%D`: Date (%m/%d/%y)
    * `%e`: Day of the month, blank-padded ( 1..31)
    * `%F`: Equivalent to %Y-%m-%d (the ISO 8601 date format)
    * `%h`: Equivalent to %b
    * `%H`: Hour of the day, 24-hour clock (00..23)
    * `%I`: Hour of the day, 12-hour clock (01..12)
    * `%j`: Day of the year (001..366)
    * `%k`: Hour, 24-hour clock, blank-padded ( 0..23)
    * `%l`: Hour, 12-hour clock, blank-padded ( 0..12)
    * `%L`: Millisecond of the second (000..999)
    * `%m`: Month of the year (01..12)
    * `%M`: Minute of the hour (00..59)
    * `%n`: Newline (\n)
    * `%N`: Fractional seconds digits, default is 9 digits (nanosecond)
      * `%3N`: Millisecond (3 digits)
      * `%6N`: Microsecond (6 digits)
      * `%9N`: Nanosecond (9 digits)
    * `%p`: Meridian indicator ('AM'  or  'PM')
    * `%P`: Meridian indicator ('am'  or  'pm')
    * `%r`: Time, 12-hour (same as %I:%M:%S %p)
    * `%R`: Time, 24-hour (%H:%M)
    * `%s`: Number of seconds since 1970-01-01 00:00:00 UTC.
    * `%S`: Second of the minute (00..60)
    * `%t`: Tab character (	)
    * `%T`: Time, 24-hour (%H:%M:%S)
    * `%u`: Day of the week as a decimal, Monday being 1. (1..7)
    * `%U`: Week  number  of the current year, starting with the first Sunday as the first day of the first week (00..53)
    * `%v`: VMS date (%e-%b-%Y)
    * `%V`: Week number of year according to ISO 8601 (01..53)
    * `%W`: Week  number of the current year, starting with the first Monday as the first day of the first week (00..53)
    * `%w`: Day of the week (Sunday is 0, 0..6)
    * `%x`: Preferred representation for the date alone, no time
    * `%X`: Preferred representation for the time alone, no date
    * `%y`: Year without a century (00..99)
    * `%Y`: Year with century
    * `%z`: Time zone as  hour offset from UTC (e.g. +0900)
    * `%Z`: Time zone name
    * `%%`: Literal '%' character

* `strip`: This function removes leading and trailing whitespace from a string or from every string inside an array. For example, `strip("    aaa   ")` results in "aaa". *Type*: rvalue

* `suffix`: This function applies a suffix to all elements in an array. For example, `suffix(['a','b','c'], 'p')` returns ['ap','bp','cp']. *Type*: rvalue

* `swapcase`: This function swaps the existing case of a string. For example, `swapcase("aBcD")` results in "AbCd". *Type*: rvalue

* `time`: This function returns the current time since epoch as an integer. For example, `time()` returns something like '1311972653'. *Type*: rvalue

* `to_bytes`: Converts the argument into bytes, for example 4 kB becomes 4096.
Takes a single string value as an argument. *Type*: rvalue

* `type3x`: Returns a string description of the type when passed a value. Type can be a string, array, hash, float, integer, or boolean. This function will be removed when puppet 3 support is dropped and the new type system may be used. *Type*: rvalue

* `type_of`: Returns the literal type when passed a value. Requires the new
  parser. Useful for comparison of types with `<=` such as in `if
  type_of($some_value) <= Array[String] { ... }` (which is equivalent to `if
  $some_value =~ Array[String] { ... }`) *Type*: rvalue

* `union`: This function returns a union of two arrays. For example, `union(["a","b","c"],["b","c","d"])` returns ["a","b","c","d"].

* `unique`: This function removes duplicates from strings and arrays. For example, `unique("aabbcc")` returns 'abc'.

You can also use this with arrays. For example, `unique(["a","a","b","b","c","c"])` returns ["a","b","c"]. *Type*: rvalue

* `upcase`: Converts an object, array or hash of objects that respond to upcase to uppercase. For example, `upcase("abcd")` returns 'ABCD'.  *Type*: rvalue

* `uriescape`: Urlencodes a string or array of strings. Requires either a single string or an array as an input. *Type*: rvalue

* `validate_absolute_path`: Validate the string represents an absolute path in the filesystem.  This function works for Windows and Unix style paths.

    The following values will pass:

    ```
    $my_path = 'C:/Program Files (x86)/Puppet Labs/Puppet'
    validate_absolute_path($my_path)
    $my_path2 = '/var/lib/puppet'
    validate_absolute_path($my_path2)
    $my_path3 = ['C:/Program Files (x86)/Puppet Labs/Puppet','C:/Program Files/Puppet Labs/Puppet']
    validate_absolute_path($my_path3)
    $my_path4 = ['/var/lib/puppet','/usr/share/puppet']
    validate_absolute_path($my_path4)
    ```

    The following values will fail, causing compilation to abort:

    ```
    validate_absolute_path(true)
    validate_absolute_path('../var/lib/puppet')
    validate_absolute_path('var/lib/puppet')
    validate_absolute_path([ 'var/lib/puppet', '/var/foo' ])
    validate_absolute_path([ '/var/lib/puppet', 'var/foo' ])
    $undefined = undef
    validate_absolute_path($undefined)
    ```

    *Type*: statement

* `validate_array`: Validate that all passed values are array data structures. Abort catalog compilation if any value fails this check.

  The following values will pass:

  ```
  $my_array = [ 'one', 'two' ]
  validate_array($my_array)
  ```

  The following values will fail, causing compilation to abort:

  ```
  validate_array(true)
  validate_array('some_string')
  $undefined = undef
  validate_array($undefined)
  ```

  *Type*: statement

* `validate_augeas`: Performs validation of a string using an Augeas lens.
The first argument of this function should be the string to test, and the second argument should be the name of the Augeas lens to use. If Augeas fails to parse the string with the lens, the compilation aborts with a parse error.

  A third optional argument lists paths which should **not** be found in the file. The `$file` variable points to the location of the temporary file being tested in the Augeas tree.

  For example, to make sure your passwd content never contains user `foo`:

  ```
  validate_augeas($passwdcontent, 'Passwd.lns', ['$file/foo'])
  ```

  To ensure that no users use the '/bin/barsh' shell:

  ```
  validate_augeas($passwdcontent, 'Passwd.lns', ['$file/*[shell="/bin/barsh"]']
  ```

  You can pass a fourth argument as the error message raised and shown to the user:

  ```
  validate_augeas($sudoerscontent, 'Sudoers.lns', [], 'Failed to validate sudoers content with Augeas')
  ```

  *Type*: statement

* `validate_bool`: Validate that all passed values are either true or false. Abort catalog compilation if any value fails this check.

  The following values will pass:

  ```
  $iamtrue = true
  validate_bool(true)
  validate_bool(true, true, false, $iamtrue)
  ```

  The following values will fail, causing compilation to abort:

  ```
  $some_array = [ true ]
  validate_bool("false")
  validate_bool("true")
  validate_bool($some_array)
  ```

  *Type*: statement

* `validate_cmd`: Performs validation of a string with an external command. The first argument of this function should be a string to test, and the second argument should be a path to a test command taking a % as a placeholder for the file path (will default to the end of the command if no % placeholder given). If the command, launched against a tempfile containing the passed string, returns a non-null value, compilation will abort with a parse error.

If a third argument is specified, this will be the error message raised and seen by the user.

  ```
  # Defaults to end of path
  validate_cmd($sudoerscontent, '/usr/sbin/visudo -c -f', 'Visudo failed to validate sudoers content')
  ```
  ```
  # % as file location
  validate_cmd($haproxycontent, '/usr/sbin/haproxy -f % -c', 'Haproxy failed to validate config content')
  ```

  *Type*: statement

* `validate_hash`: Validates that all passed values are hash data structures. Abort catalog compilation if any value fails this check.

  The following values will pass:

  ```
  $my_hash = { 'one' => 'two' }
  validate_hash($my_hash)
  ```

  The following values will fail, causing compilation to abort:

  ```
  validate_hash(true)
  validate_hash('some_string')
  $undefined = undef
  validate_hash($undefined)
  ```

  *Type*: statement

* `validate_integer`: Validate that the first argument is an integer (or an array of integers). Abort catalog compilation if any of the checks fail.
    
  The second argument is optional and passes a maximum. (All elements of) the first argument has to be less or equal to this max.

  The third argument is optional and passes a minimum.  (All elements of) the first argument has to be greater or equal to this min.
  If, and only if, a minimum is given, the second argument may be an empty string or undef, which will be handled to just check
  if (all elements of) the first argument are greater or equal to the given minimum.

  It will fail if the first argument is not an integer or array of integers, and if arg 2 and arg 3 are not convertable to an integer.

  The following values will pass:

  ```
  validate_integer(1)
  validate_integer(1, 2)
  validate_integer(1, 1)
  validate_integer(1, 2, 0)
  validate_integer(2, 2, 2)
  validate_integer(2, '', 0)
  validate_integer(2, undef, 0)
  $foo = undef
  validate_integer(2, $foo, 0)
  validate_integer([1,2,3,4,5], 6)
  validate_integer([1,2,3,4,5], 6, 0)
  ```

  * Plus all of the above, but any combination of values passed as strings ('1' or "1").
  * Plus all of the above, but with (correct) combinations of negative integer values.

  The following values will fail, causing compilation to abort:

  ```
  validate_integer(true)
  validate_integer(false)
  validate_integer(7.0)
  validate_integer({ 1 => 2 })
  $foo = undef
  validate_integer($foo)
  validate_integer($foobaridontexist)

  validate_integer(1, 0)
  validate_integer(1, true)
  validate_integer(1, '')
  validate_integer(1, undef)
  validate_integer(1, , 0)
  validate_integer(1, 2, 3)
  validate_integer(1, 3, 2)
  validate_integer(1, 3, true)
  ```

  * Plus all of the above, but any combination of values passed as strings ('false' or "false").
  * Plus all of the above, but with incorrect combinations of negative integer values.
  * Plus all of the above, but with non-integer crap in arrays or maximum / minimum argument.

  *Type*: statement

* `validate_numeric`: Validate that the first argument is a numeric value (or an array of numeric values). Abort catalog compilation if any of the checks fail.

  The second argument is optional and passes a maximum. (All elements of) the first argument has to be less or equal to this max.

  The third argument is optional and passes a minimum.  (All elements of) the first argument has to be greater or equal to this min.
  If, and only if, a minimum is given, the second argument may be an empty string or undef, which will be handled to just check
  if (all elements of) the first argument are greater or equal to the given minimum.

  It will fail if the first argument is not a numeric (Integer or Float) or array of numerics, and if arg 2 and arg 3 are not convertable to a numeric.

  For passing and failing usage, see `validate_integer()`. It is all the same for validate_numeric, yet now floating point values are allowed, too.

  *Type*: statement

* `validate_re`: Performs simple validation of a string against one or more regular expressions. The first argument of this function should be the string to
test, and the second argument should be a stringified regular expression
(without the // delimiters) or an array of regular expressions. If none
of the regular expressions match the string passed in, compilation aborts with a parse error.

  You can pass a third argument as the error message raised and shown to the user.

  The following strings validate against the regular expressions:

  ```
  validate_re('one', '^one$')
  validate_re('one', [ '^one', '^two' ])
  ```

  The following string fails to validate, causing compilation to abort:

  ```
  validate_re('one', [ '^two', '^three' ])
  ```

  To set the error message:

  ```
  validate_re($::puppetversion, '^2.7', 'The $puppetversion fact value does not match 2.7')
  ```

  *Type*: statement

* `validate_slength`: Validates that the first argument is a string (or an array of strings), and is less than or equal to the length of the second argument. It fails if the first argument is not a string or array of strings, or if arg 2 is not convertable to a number.

  The following values pass:

  ```
  validate_slength("discombobulate",17)
  validate_slength(["discombobulate","moo"],17)
  ```

  The following values fail:

  ```
  validate_slength("discombobulate",1)
  validate_slength(["discombobulate","thermometer"],5)
  ```

  *Type*: statement

* `validate_string`: Validates that all passed values are string data structures. Aborts catalog compilation if any value fails this check.

  The following values pass:

  ```
  $my_string = "one two"
  validate_string($my_string, 'three')
  ```

  The following values fail, causing compilation to abort:

  ```
  validate_string(true)
  validate_string([ 'some', 'array' ])
  $undefined = undef
  validate_string($undefined)
  ```

  *Type*: statement

* `values`: When given a hash, this function returns the values of that hash.

  *Examples:*

  ```
  $hash = {
    'a' => 1,
    'b' => 2,
    'c' => 3,
  }
  values($hash)
  ```

  The example above returns [1,2,3].

  *Type*: rvalue

* `values_at`: Finds value inside an array based on location. The first argument is the array you want to analyze, and the second element can be a combination of:

  * A single numeric index
  * A range in the form of 'start-stop' (eg. 4-9)
  * An array combining the above

  For example, `values_at(['a','b','c'], 2)` returns ['c']; `values_at(['a','b','c'], ["0-1"])` returns ['a','b']; and `values_at(['a','b','c','d','e'], [0, "2-3"])` returns ['a','c','d'].

  *Type*: rvalue

* `zip`: Takes one element from first array and merges corresponding elements from second array. This generates a sequence of n-element arrays, where n is one more than the count of arguments. For example, `zip(['1','2','3'],['4','5','6'])` results in ["1", "4"], ["2", "5"], ["3", "6"]. *Type*: rvalue

##Limitations

As of Puppet Enterprise version 3.7, the stdlib module is no longer included in PE. PE users should install the most recent release of stdlib for compatibility with Puppet modules.

###Version Compatibility

Versions | Puppet 2.6 | Puppet 2.7 | Puppet 3.x | Puppet 4.x |
:---------------|:-----:|:---:|:---:|:----:
**stdlib 2.x**  | **yes** | **yes** | no | no
**stdlib 3.x**  | no    | **yes**  | **yes** | no
**stdlib 4.x**  | no    | **yes**  | **yes** | no
**stdlib 5.x**  | no    | no  | **yes**  | **yes**

**stdlib 5.x**: When released, stdlib 5.x will drop support for Puppet 2.7.x. Please see [this discussion](https://github.com/puppetlabs/puppetlabs-stdlib/pull/176#issuecomment-30251414).

##Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide on the [Puppet Labs wiki](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing).

To report or research a bug with any part of this module, please go to
[http://tickets.puppetlabs.com/browse/PUP](http://tickets.puppetlabs.com/browse/PUP).

##Contributors

The list of contributors can be found at: https://github.com/puppetlabs/puppetlabs-stdlib/graphs/contributors




