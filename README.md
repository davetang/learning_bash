# Learning Bash
2024-05-24

- [Bash scripting](#bash-scripting)
- [Data structures](#data-structures)
- [Strict mode](#strict-mode)
- [Functions](#functions)
- [Variables](#variables)
  - [Built-in variables](#built-in-variables)
- [Regular expressions and globbing](#regular-expressions-and-globbing)
- [String manipulation](#string-manipulation)
- [Debugging](#debugging)
- [Best practices](#best-practices)
- [Further reading](#further-reading)
- [Version](#version)

![Build
README](https://github.com/davetang/learning_bash/actions/workflows/create_readme.yml/badge.svg)

A shell is any user interface to the Linux/UNIX operating system; it is
external to the kernel (like an actual shell, exoskeleton) and
translates user input into instructions the operating system can
interpret.

[Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) is a Unix shell
that is widely used as the default login shell for many Linux
distributions. It was the default login shell for macOS, until they
switched to zsh, possibly because of the
[license](https://discussions.apple.com/thread/250722978) attached to
Bash. I use Bash since it’s the default shell for the two Linux
distributions I use the most (CentOS and Ubuntu).

Bash is an abbreviation for Bourne again shell, a naming pun for Steve
Bourne’s shell and was created for use in the [GNU
project](https://www.gnu.org/home.en.html). The GNU project was started
for the purpose of creating a UNIX-compatible operating system and
replacing all commercial UNIX utilities with freely distributable
versions.

There are two ways to use `bash`: as a command line interface and as a
programming environment. These notes mostly pertain to the use of Bash
as a programming/scripting language.

## Bash scripting

A Bash *script* or *program* is simply a file that contains Bash
commands. Your `.bash_profile` and `.bashrc` files are Bash scripts. You
can run a Bash script using the `source my_script` command or using
`bash my_script` (or by adding `#!/usr/bin/env bash` to the start of
your script and making your file executable, i.e. `chmod 755 my_script`)
but there is an important difference between the two. Using `source`
causes the commands in the script to be run as if they were part of your
login session, where as using `bash` will run the script in a
*subshell*. This means that a copy of the shell, which is a subprocess
of the parent, is invoked.

Subshells inherit the following from their parents:

- The current directory
- Environment variables
- Standard input, output, and error, plus any other open file
  descriptors
- Signals that are ignored

Subshells do not inherit the following from their parents:

- Shell variables
- Handling of signals that are not ignored

## Data structures

[Bash variables are untyped](https://tldp.org/LDP/abs/html/untyped.html)
and they are essentially character strings but if a variable contains
only digits, Bash allows simple arithmetic operations.

``` bash
x=1985
echo $(( x - 1 ))
```

    1984

Note what happens when a variable is a string.

``` bash
x='nine'
echo $(( x - 1 ))
```

    -1

``` bash
x=nineteeneightyfour
echo $(( x - 1 ))
```

    -1

Be careful when using untyped variables.

``` bash
x=nineteeneightyfour
xx=$(( x - 1 ))
echo $(( xx + 1985))
```

    1984

Bash supports indexed arrays and associative arrays (also known as
hashes or dictionaries). Since Bash variables are untyped, array
elements can contain characters and numbers.

The easiest way to manually create an indexed array is to use
parentheses. Arrays are zero-indexed.

``` bash
fruits=( apple banana cherry durian elderberry )

echo ${fruits[0]}
```

    apple

Negative indexing is supported.

``` bash
fruits=( apple banana cherry durian elderberry )
echo ${fruits[-1]}
echo ${fruits[-2]}
```

    elderberry
    durian

Use this syntax to refer to all elements.

``` bash
fruits=( apple banana cherry durian elderberry )
echo ${fruits[@]}
```

    apple banana cherry durian elderberry

Associative arrays must be declared before they are created using
`declare` and `-A`. Elements are referenced using square brackets not
braces.

``` bash
declare -A fruits_hash

fruits_hash=(
  [a]=apple
  [b]=banana
  [c]=cherry
  [d]=durian
  [e]=elderberry
)

echo ${fruits_hash[a]}
echo ${fruits_hash[c]}
```

    apple
    cherry

Use the following syntax to get the array length.

``` bash
fruits=( apple banana cherry durian elderberry )
echo ${#fruits[@]}
```

    5

Use the following syntax to get all the indexes.

``` bash
fruits=( apple banana cherry durian elderberry )
echo ${!fruits[@]}
```

    0 1 2 3 4

Loop through each element.

``` bash
fruits=( apple banana cherry durian elderberry )
for i in ${fruits[@]}; do
  echo ${i}
done
```

    apple
    banana
    cherry
    durian
    elderberry

Loop through each element’s index.

``` bash
fruits=( apple banana cherry durian elderberry )
for i in ${!fruits[@]}; do
  echo ${i}
done
```

    0
    1
    2
    3
    4

Loop through each element’s index, i.e. the key.

``` bash
declare -A fruits_hash

fruits_hash=(
  [a]=apple
  [b]=banana
  [c]=cherry
  [d]=durian
  [e]=elderberry
)
for i in ${!fruits_hash[@]}; do
  echo ${i}
done
```

    e
    d
    c
    b
    a

Use `unset` to delete an element (even if it is in the middle of an
array).

``` bash
fruits=( apple banana cherry durian elderberry )
unset fruits[3]
echo ${fruits[@]}
```

    apple banana cherry elderberry

It seems that [2D arrays are
possible](https://www.baeldung.com/linux/bash-2d-arrays) but if you need
a 2D array, you should perhaps consider another scripting language
(Python, Perl, etc.).

## Strict mode

Notes adapted and expanded from [Better Bash Scripting in 15
Minutes](https://robertmuth.blogspot.com/2012/08/better-bash-scripting-in-15-minutes.html).

Starting Bash scripts with the following:

``` bash
#!/usr/bin/env bash
set -o nounset
set -o errexit
```

will deal with two very common errors:

1.  Referencing undefined variables, which defaults to ’’
2.  Ignoring failing commands

They are the same as `-u` and `-e`, which you may be familiar with when
using the unofficial Bash strict mode `set -euo pipefail`. The longer
versions are more readable and therefore may be more preferable.

Sometimes you do not want a script to exit when a command fails and this
can be achieved by using the following idiom:

``` bash
#!/usr/bin/env bash
set -o nounset
set -o errexit

# the grep command will cause the script to exit because grep returns an exit
# code > 0 when it has no matches
# grep nothing README.md

# use the following to ignore a "failing" command
if ! grep nothing README.md ; then
   >&2 echo "Failure ignored"
fi

>&2 echo "Done"
exit 0
```

## Functions

The basic syntax of a function is:

``` bash
function_name(){
}
```

When passing arguments to Bash functions:

- The passed parameters are `$1`, `$2`, `$3`, …, \$n, corresponding to
  the position of the parameter after the function’s name.
- The `$0` variable is reserved for the function’s name (but this
  doesn’t seem like the case in the example below).
- The `$#` variable holds the number of positional parameters/arguments
  passed to the function.
- The `$*` and `$@` variables hold all positional parameters/arguments
  passed to the function.
- When double-quoted, `"$*"` expands to a **single string** separated by
  space (or what IFS is set to) - “\$1 \$2 \$n”.
- When double-quoted, `"$@"` expands to separate strings - “\$1”
  “![2" "](https://latex.codecogs.com/svg.latex?2%22%20%22 "2" "")n”.
- When not double-quoted, `$*` and `$@` are the same.

``` bash
my_func(){
   echo $0
   echo function name is ${FUNCNAME[0]}
   echo first arg is $1
   echo $# args passed
   echo $*
   echo $@
}

my_func one two three
```

    bash
    function name is my_func
    first arg is one
    3 args passed
    one two three
    one two three

Bash lets you define functions that behave like other commands.

``` bash
extract_comment(){
  grep "^#"
}

cat script/ignore_exit_code.sh | extract_comment
```

    #!/usr/bin/env bash
    # the grep command will cause the script to exit because grep returns an exit
    # code > 0 when it has no matches
    # grep nothing README.md
    # use the following construct to ignore a "failing" command

Redirect input to the function.

``` bash
extract_comment(){
  grep "^#"
}
comments=$(extract_comment < script/ignore_exit_code.sh)
echo ${comments}
```

    #!/usr/bin/env bash # the grep command will cause the script to exit because grep returns an exit # code > 0 when it has no matches # grep nothing README.md # use the following construct to ignore a "failing" command

Function to sum numbers (one per line) in a file. Local scope is
achieved using `local`, which means that the variable is only visible
within a block of code, i.e. the function.

``` bash
# iterating over stdin
sum_line(){
    local sum=0
    local line=''
    while read line ; do
        sum=$((${sum} + ${line}))
    done
    >&2 echo ${sum}
}

echo -e '1\n2\n3\n4\n5' > num.txt
sum_line < num.txt

rm num.txt
```

    15

A classic logger that makes use of `$@`, which contains all arguments
passed to the function.

``` bash
log(){
   local prefix="[$(date +%Y/%m/%d\ %H:%M:%S)]: "
   >&2 echo "${prefix} $@"
}
log "INFO" "a message"
```

    [2024/05/24 01:31:03]:  INFO a message

## Variables

Use `local` to set local scoping for variables but this seems to be for
use with functions only.

``` bash
local x=14
```

    bash: line 1: local: can only be used in a function

Use `readonly` to set immutable variables.

``` bash
readonly x=1984
echo ${x}

x=2023
```

    1984
    bash: line 4: x: readonly variable

Note that you cannot `unset` a readonly variable; it exists until the
shell exits.

Assign variable or output an error, which is a useful shortcut to check
whether an argument was passed to a function.

``` bash
say(){
   smt=${1?Error: missing input}
   echo ${smt}
}

# this exits with a code of 1
say
# echo $?
# 1
```

    Error in running command bash

Functions works as intended when an argument is passed.

``` bash
say(){
   smt=${1?Error: missing input}
   echo ${smt}
}

say meow
```

    meow

You can also set a default value, instead exiting with an error.

``` bash
say2(){
   smt=${1:-something}
   echo ${smt}
}

say2

say2 nothing
```

    something
    nothing

### Built-in variables

Some useful built-in variables.

- `$0` - name of the script
- `$n` - positional parameters to script/function
- `$$` - PID of the script
- `$!` - PID of the last command executed (and run in the background)
- `$?` - exit status of the last command (`${PIPESTATUS}` for pipelined
  commands)
- `$#` - number of parameters to script/function
- `$@` - all parameters to script/function (sees arguments as separate
  word)
- `$*` - all parameters to script/function (sees arguments as single
  word)

## Regular expressions and globbing

Globbing is a method for creating patterns that is used for matching;
use `==` for string matching with globbing.

Globbing will return true.

``` bash
t="abc123"

[[ "$t" == abc* ]] && echo True
```

    True

Literal matching is turned on with quotes.

``` bash
t="abc123"
[[ "$t" == 'abc*' ]] || echo False
[[ "$t" == "abc*" ]] || echo False
```

    False
    False

Use `=~` for regular expression matching, which is only supported using
double brackets.

``` bash
t="abc123"
[[ "$t" =~ [abc]+[123]+ ]] && echo True
```

    True

Literal matching is turned on again with quotes.

``` bash
t="abc123"
[[ "$t" =~ "abc*" ]] || echo False
```

    False

## String manipulation

Length of a string.

``` bash
#  01234567890123456789
f="path1/path2/file.ext"
echo ${#f}
```

    20

Slicing syntax: `${<var>:<start>}` or `${<var>:<start>:<length>}` where
the position is 0-based.

Start from position 6.

``` bash
#  01234567890123456789
f="path1/path2/file.ext"
echo ${f:6}
```

    path2/file.ext

Start from position 6, and output 5 characters.

``` bash
f="path1/path2/file.ext"
echo ${f:6:5}
```

    path2

Negative indexing; note the space before “-”.

``` bash
f="path1/path2/file.ext"
echo "${f: -8}"
```

    file.ext

Single substitution with globbing.

``` bash
f="path1/path2/file.ext"
echo ${f/path?/path3}
```

    path3/path2/file.ext

Global substitution with globbing.

``` bash
f="path1/path2/file.ext"
echo ${f//path?/path3}
```

    path3/path3/file.ext

Splitting; note the space before the right brace, which is used for the
splitting.

``` bash
f="path1/path2/file.ext"
sep="/"
array=(${f//${sep}/ })
echo ${array[@]}
```

    path1 path2 file.ext

Deletion with globbing; delete everything before the period.

``` bash
f="path1/path2/file.ext"
echo ${f#*.}
```

    ext

Non-greedy deletion at start of string.

``` bash
f="path1/path2/file.ext"
echo ${f#*/}
```

    path2/file.ext

Use extra `#` for greedy deletion at start of string.

``` bash
f="path1/path2/file.ext"
echo ${f##*/}
```

    file.ext

Non-greedy deletion starting from string end; delete everything until
matching a `/` (including the `/`).

``` bash
f="path1/path2/file.ext"
echo ${f%/*}
```

    path1/path2

Greedy deletion from the end.

``` bash
f="path1/path2/file.ext"
echo ${f%%/*}
```

    path1

## Debugging

To perform a syntax check/dry run of a Bash script:

``` bash
bash -n script/ignore_exit_code.sh
```

To produce a trace of every command executed run:

``` bash
bash -v script/ignore_exit_code.sh
```

    #!/usr/bin/env bash
    set -o nounset
    set -o errexit

    # the grep command will cause the script to exit because grep returns an exit
    # code > 0 when it has no matches
    # grep nothing README.md

    script_dir=$(realpath $(dirname $0))
    infile=${script_dir}/../README.md

    # use the following construct to ignore a "failing" command
    if ! grep -q not_going_to_find_this ${infile} ; then
       >&2 echo "Failure ignored; continuing..."
    fi

    if grep -q e ${infile} ; then
       >&2 echo "The letter [e] was found in ${infile}"
    fi
    The letter [e] was found in /home/runner/work/learning_bash/learning_bash/script/../README.md

    >&2 echo "Done"
    Done
    exit 0

To produce a trace of the expanded command use:

``` bash
bash -x script/ignore_exit_code.sh
```

    + set -o nounset
    + set -o errexit
    +++ dirname script/ignore_exit_code.sh
    ++ realpath script
    + script_dir=/home/runner/work/learning_bash/learning_bash/script
    + infile=/home/runner/work/learning_bash/learning_bash/script/../README.md
    + grep -q not_going_to_find_this /home/runner/work/learning_bash/learning_bash/script/../README.md
    + grep -q e /home/runner/work/learning_bash/learning_bash/script/../README.md
    + echo 'The letter [e] was found in /home/runner/work/learning_bash/learning_bash/script/../README.md'
    The letter [e] was found in /home/runner/work/learning_bash/learning_bash/script/../README.md
    + echo Done
    Done
    + exit 0

`-v` and `-x` can also be made permanent by adding `set -o verbose` and
`set -o xtrace` to the script.

## Best practices

- The `biotool` directory in this repository contains a script (also
  called `biotool`) that follows [Ten recommendations for creating
  usable bioinformatics command line
  software](https://academic.oup.com/gigascience/article/2/1/2047-217X-2-15/2656133).
  Open the script up in your favourite editor to see how each of the
  recommendations can be followed using Bash.

- A lot of Bash syntax is obscure, which minimises typing, but makes it
  hard to read. I highly recommend adding comments to your code.

- Start each script with `#!/usr/bin/env bash` then with
  `set -euo pipefail`

  - `-e` is short for `errexit` and if a command fails your script will
    exit.
  - `-u` is short for `nounset` and your script will exit when a
    variable is undeclared.
  - `pipefail` sets the result of a pipeline to a non-zero status if any
    command in the pipeline had a non-zero status.
  - `set -euo pipefail` can be split up if you think it is more readable

``` bash
set -o nounset
set -o errexit
set -o pipefail
```

- Note that some commands exit with a non-zero status, even if it did
  “not fail”.

``` bash
echo hi | grep no
echo $?
```

    1

- You can consider using `. my.sh` instead of `source my.sh`; the former
  is the POSIX-standard for executing commands whereas the latter is
  specific to some shells like Bash. But since this is a Bash guide, I
  consider it fine to keep using `source`, which is also more readable.

- I prefer using `${var}` instead of `$var` for all variables.

- I also prefer snake_case over camelCase.

- Warnings and errors should go to `STDERR` and I like to include the
  redirection at the front because it is more readable. The following
  commands are the same; you be the judge of which is more readable.

``` bash
>&2 echo ERROR
echo ERROR >&2
```

    ERROR
    ERROR

- To make variables local to a function, declare them with the `local`
  builtin command. Refer to the [Variables](#variables) section.

- Use `$()` instead of backticks ``` `` ``` because it is easier to
  specify and see nested subshells using `$()`.

- A side note about the difference between `()` and `$()`; the former is
  for grouping commands together in a subshell
  `(echo Hello; echo World)` and the latter is meant for command
  substitution where it makes it convenient to store command outputs as
  a variable `ME=$(whoami)`.

- Use `[[]]` (double brackets) over `[]` because it offers syntactical
  improvements and new functionality

  - `||` - logical or (double brackets only)
  - `&&` - logical and (double brackets only)
  - `<` - string comparison (no escaping necessary within double
    brackets)
  - `=` - string matching with globbing
  - `==` - string matching with globbing (double brackets only)
  - `=~` - string matching with regular expressions (double brackets
    only)
  - `-n` - string is non-empty
  - `-z` - string is empty
  - `-eq` - numerical equality
  - `-lt` - numerical comparison
  - `-ne` - numerical inequality

- Avoid temporary files by using the `<()` operator, which transforms a
  command into something that can be used as a filename,
  e.g. `diff <(wget -O - URL1)   <(wget -O - URL2)`.

- Heredocs are handy for passing multi-line strings to a command. Note
  how variable interpolation is set.

Variable interpolation.

``` bash
var=test
cat << EOF
one
${var}
three
EOF
```

    one
    test
    three

No variable interpolation.

``` bash
var=test
cat << 'EOF'
one
${var}
three
EOF
```

    one
    ${var}
    three

- If your script is getting big (over 100 lines), consider splitting it
  up into functions stored in different files.

- Lastly, if your code is getting too complicated, consider using
  another programming language. They all have their advantages and
  disadvantages, so try to pick one that suits your problem. Python is
  often a good choice for many different problems.

## Further reading

- [Advanced Bash scripting guide](https://tldp.org/LDP/abs/html/)
- [Bash reference
  manual](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html)

## Version

Bash version used to generate this document.

``` bash
bash --version
```

    GNU bash, version 5.1.16(1)-release (x86_64-pc-linux-gnu)
    Copyright (C) 2020 Free Software Foundation, Inc.
    License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

    This is free software; you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law.
