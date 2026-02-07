# Learning Bash
2026-02-07

- [Bash scripting](#bash-scripting)
- [Input handling](#input-handling)
- [Output redirection and pipes](#output-redirection-and-pipes)
- [Data structures](#data-structures)
- [Quoting](#quoting)
- [Strict mode](#strict-mode)
- [Functions](#functions)
- [Variables](#variables)
  - [Built-in variables](#built-in-variables)
- [Arithmetic](#arithmetic)
- [Command substitution](#command-substitution)
- [Regular expressions and globbing](#regular-expressions-and-globbing)
- [String manipulation](#string-manipulation)
- [Conditionals](#conditionals)
- [Case statements](#case-statements)
- [Loops](#loops)
  - [for loop](#for-loop)
  - [while loop](#while-loop)
  - [until loop](#until-loop)
  - [break and continue](#break-and-continue)
  - [Looping over lines in a file](#looping-over-lines-in-a-file)
- [Reading user input](#reading-user-input)
- [Exit codes and return values](#exit-codes-and-return-values)
- [Traps and signal handling](#traps-and-signal-handling)
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

## Input handling

In Linux, `<`, `<<`, and `<<<` are redirection operators used for input
handling.

- `<` (input redirection) - redirects input from a file to a command
  instead of reading from standard input.

``` bash
printf "13\n1\n31\n" > test.txt

sort < test.txt
wc -l < test.txt
```

    1
    13
    31
    3

- `<<` (here doc) - creates a multi-line input block that continues
  until it encounters a specified delimiter (often `EOF`).

``` bash
cat << EOF
This is line 1
This is line 2
This is line 3
EOF
```

    This is line 1
    This is line 2
    This is line 3

- `<<<` (here string) - passes a string directly as input to a command.

``` bash
grep 1984 <<< "The year is 1984."
awk '{print $1 + $2}' <<< "1900 84"
```

    The year is 1984.
    1984

Summary:

- `<` reads from an existing file.
- `<<` creates temporary multi-line input.
- `<<<` provides immediate string input.

## Output redirection and pipes

Output redirection lets you control where command output goes. Standard
output (stdout) is file descriptor 1 and standard error (stderr) is file
descriptor 2.

- `>` (overwrite) - redirects stdout to a file, creating or overwriting
  it.

``` bash
echo "hello" > /tmp/out.txt
cat /tmp/out.txt
```

    hello

- `>>` (append) - redirects stdout and appends to a file.

``` bash
echo "world" >> /tmp/out.txt
cat /tmp/out.txt
rm /tmp/out.txt
```

    hello
    world

- `2>` - redirects stderr to a file.

``` bash
ls /nonexistent 2> /tmp/err.txt
cat /tmp/err.txt
rm /tmp/err.txt
```

    ls: cannot access '/nonexistent': No such file or directory

- `&>` - redirects both stdout and stderr to a file.

``` bash
ls /nonexistent &> /tmp/all.txt
cat /tmp/all.txt
rm /tmp/all.txt
```

    ls: cannot access '/nonexistent': No such file or directory

- `2>&1` - redirects stderr to wherever stdout is going. This is useful
  for combining streams in a pipeline.

``` bash
ls /nonexistent 2>&1 | grep -i "no such"
```

    ls: cannot access '/nonexistent': No such file or directory

- `|` (pipe) - sends stdout of one command as stdin to another command.

``` bash
echo -e "cherry\napple\nbanana" | sort
```

    apple
    banana
    cherry

- `tee` - reads from stdin and writes to both stdout and a file
  simultaneously. This is useful for saving intermediate output while
  still passing it through a pipeline.

``` bash
echo -e "cherry\napple\nbanana" | tee /tmp/unsorted.txt | sort
echo "---"
cat /tmp/unsorted.txt
rm /tmp/unsorted.txt
```

    apple
    banana
    cherry
    ---
    cherry
    apple
    banana

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

## Quoting

Quoting controls how Bash interprets special characters. There are three
main forms: single quotes, double quotes, and no quotes.

Single quotes preserve everything literally; no variable expansion or
special character interpretation occurs.

``` bash
x=1984
echo '${x} is not expanded'
echo 'special chars: * ? ~ $ ! are literal'
```

    ${x} is not expanded
    special chars: * ? ~ $ ! are literal

Double quotes allow variable expansion and command substitution but
prevent word splitting and globbing.

``` bash
x=1984
echo "The year is ${x}"
echo "Today is $(date +%A)"
```

    The year is 1984
    Today is Saturday

Without quotes, Bash performs word splitting and globbing on the result.
This can lead to unexpected behaviour.

``` bash
msg="hello     world"

# without quotes: extra spaces are lost due to word splitting
echo ${msg}

# with quotes: spaces are preserved
echo "${msg}"
```

    hello world
    hello     world

Use a backslash to escape special characters.

``` bash
echo "A double quote: \" inside double quotes"
echo 'Use '\''single quote'\'' inside single quotes'
echo "A literal dollar sign: \$HOME"
```

    A double quote: " inside double quotes
    Use 'single quote' inside single quotes
    A literal dollar sign: $HOME

Quoting is especially important when dealing with filenames that contain
spaces or special characters, and when passing arguments that should
remain as a single word.

``` bash
file="my file.txt"
touch "${file}"
ls -la "${file}"
rm "${file}"
```

    -rw-r--r-- 1 1001 1001 0 Feb  7 14:19 my file.txt

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

    [2026/02/07 14:19:44]:  INFO a message

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

## Arithmetic

Bash supports integer arithmetic using `$(( ))` for arithmetic expansion
and `(( ))` for arithmetic evaluation.

Common operators: `+`, `-`, `*`, `/` (integer division), `%` (modulus),
`**` (exponentiation).

``` bash
echo $(( 10 + 3 ))
echo $(( 10 - 3 ))
echo $(( 10 * 3 ))
echo $(( 10 / 3 ))
echo $(( 10 % 3 ))
echo $(( 2 ** 10 ))
```

    13
    7
    30
    3
    1
    1024

Use `(( ))` for arithmetic evaluation, which is useful for incrementing
variables and in conditions.

``` bash
x=0
(( x++ ))
echo ${x}
(( x += 10 ))
echo ${x}
```

    1
    11

Use `(( ))` as a condition in `if` statements. It returns 0 (true) if
the expression is non-zero, and 1 (false) if the expression is zero.

``` bash
x=42
if (( x > 40 )); then
  echo "${x} is greater than 40"
fi
```

    42 is greater than 40

For floating-point arithmetic, use `awk` or `bc` since Bash only
supports integers natively.

``` bash
echo "10 / 3" | bc -l
awk 'BEGIN { printf "%.2f\n", 10 / 3 }'
```

    bash: line 1: bc: command not found
    3.33

## Command substitution

Command substitution allows you to capture the output of a command and
use it as a value. The syntax is `$(command)`.

``` bash
current_date=$(date +%Y-%m-%d)
echo "Today is ${current_date}"
```

    Today is 2026-02-07

``` bash
num_files=$(ls | wc -l)
echo "There are ${num_files} items in the current directory"
```

    There are 11 items in the current directory

Command substitutions can be nested.

``` bash
echo "The parent directory is $(basename $(dirname $(pwd)))"
```

    The parent directory is learning_bash

You can also use command substitution inline.

``` bash
echo "Logged in as $(whoami) on $(hostname)"
```

    whoami: cannot find name for user ID 1001
    Logged in as  on 80e2651f311a

The older backtick syntax `` `command` `` is equivalent but harder to
read and nest, so `$()` is preferred (see [Best
practices](#best-practices)).

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

## Conditionals

The `if` statement is the primary conditional construct in Bash. The
basic syntax is `if/then/elif/else/fi`.

``` bash
x=10
if [[ ${x} -gt 5 ]]; then
  echo "${x} is greater than 5"
elif [[ ${x} -eq 5 ]]; then
  echo "${x} is equal to 5"
else
  echo "${x} is less than 5"
fi
```

    10 is greater than 5

File test operators are useful for checking file properties.

- `-e` - file exists
- `-f` - is a regular file
- `-d` - is a directory
- `-r` - is readable
- `-w` - is writable
- `-x` - is executable
- `-s` - file exists and is not empty

``` bash
if [[ -f bash.qmd ]]; then
  echo "bash.qmd exists and is a regular file"
fi

if [[ -d script ]]; then
  echo "script is a directory"
fi

if [[ ! -e nonexistent ]]; then
  echo "nonexistent does not exist"
fi
```

    bash.qmd exists and is a regular file
    script is a directory
    nonexistent does not exist

String comparisons.

``` bash
name="bash"
if [[ -z "" ]]; then
  echo "empty string is zero-length"
fi

if [[ -n "${name}" ]]; then
  echo "${name} is non-empty"
fi

if [[ "${name}" == "bash" ]]; then
  echo "name is bash"
fi
```

    empty string is zero-length
    bash is non-empty
    name is bash

Combine conditions using `&&` (and) and `||` (or) inside double
brackets.

``` bash
x=15
if [[ ${x} -gt 10 && ${x} -lt 20 ]]; then
  echo "${x} is between 10 and 20"
fi
```

    15 is between 10 and 20

Short-circuit evaluation is a concise alternative for simple
conditionals.

``` bash
[[ -f bash.qmd ]] && echo "file exists"
[[ -f nonexistent ]] || echo "file does not exist"
```

    file exists
    file does not exist

## Case statements

The `case` statement matches a value against patterns, similar to a
switch statement in other languages. Each pattern is terminated by `;;`.

``` bash
fruit="banana"
case ${fruit} in
  apple)
    echo "It's an apple"
    ;;
  banana|plantain)
    echo "It's a banana or plantain"
    ;;
  *)
    echo "Unknown fruit: ${fruit}"
    ;;
esac
```

    It's a banana or plantain

`case` is useful for parsing command-line options.

``` bash
while [[ $# -gt 0 ]]; do
  case $1 in
    -v|--verbose)
      VERBOSE=1
      shift
      ;;
    -o|--output)
      OUTPUT="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done
```

## Loops

### for loop

Iterate over a list of items.

``` bash
for colour in red green blue; do
  echo ${colour}
done
```

    red
    green
    blue

Iterate over a range using brace expansion.

``` bash
for i in {1..5}; do
  echo ${i}
done
```

    1
    2
    3
    4
    5

C-style for loop.

``` bash
for (( i = 0; i < 5; i++ )); do
  echo ${i}
done
```

    0
    1
    2
    3
    4

### while loop

Execute commands as long as a condition is true.

``` bash
count=1
while [[ ${count} -le 5 ]]; do
  echo "Count: ${count}"
  (( count++ ))
done
```

    Count: 1
    Count: 2
    Count: 3
    Count: 4
    Count: 5

### until loop

Execute commands until a condition becomes true (the opposite of
`while`).

``` bash
count=1
until [[ ${count} -gt 5 ]]; do
  echo "Count: ${count}"
  (( count++ ))
done
```

    Count: 1
    Count: 2
    Count: 3
    Count: 4
    Count: 5

### break and continue

Use `break` to exit a loop early and `continue` to skip to the next
iteration.

``` bash
for i in {1..10}; do
  if [[ ${i} -eq 3 ]]; then
    continue
  fi
  if [[ ${i} -eq 7 ]]; then
    break
  fi
  echo ${i}
done
```

    1
    2
    4
    5
    6

### Looping over lines in a file

Use `while read` to process a file line by line. This is preferred over
`for` loops for reading files because it handles whitespace correctly.

``` bash
echo -e "first line\nsecond line\nthird line" > /tmp/lines.txt
while IFS= read -r line; do
  echo "Line: ${line}"
done < /tmp/lines.txt
rm /tmp/lines.txt
```

    Line: first line
    Line: second line
    Line: third line

## Reading user input

The `read` builtin reads a line from standard input and assigns it to
variables.

``` bash
read -p "Enter your name: " name
echo "Hello, ${name}"
```

Use `-r` to prevent backslash from acting as an escape character.

``` bash
echo 'path\to\file' | read -r mypath
```

Use `-a` to read input into an array.

``` bash
echo "one two three" | { read -ra words; echo "${words[1]}"; }
```

    two

Use `-t` to set a timeout (in seconds).

``` bash
if read -t 5 -p "Enter something (5 sec timeout): " input; then
  echo "You entered: ${input}"
else
  echo "Timed out"
fi
```

## Exit codes and return values

Every command in Bash returns an exit code (also called exit status or
return code). By convention, 0 means success and any non-zero value
indicates failure. The exit code of the last command is stored in `$?`.

``` bash
true
echo "Exit code of true: $?"
false
echo "Exit code of false: $?"
```

    Exit code of true: 0
    Exit code of false: 1

Use `exit` to terminate a script with a specific exit code.

``` bash
#!/usr/bin/env bash
if [[ ! -f "required_file.txt" ]]; then
  >&2 echo "Error: required_file.txt not found"
  exit 1
fi
```

Inside a function, use `return` instead of `exit`. `return` exits the
function while `exit` terminates the entire script.

``` bash
is_even(){
  if (( $1 % 2 == 0 )); then
    return 0
  else
    return 1
  fi
}

if is_even 4; then
  echo "4 is even"
fi

if ! is_even 7; then
  echo "7 is odd"
fi
```

    4 is even
    7 is odd

For pipelines, `$?` only reflects the exit code of the last command. Use
`${PIPESTATUS[@]}` to check the exit code of each command in the
pipeline.

``` bash
false | true
echo "Last exit code: $?"
false | true
echo "Pipeline exit codes: ${PIPESTATUS[@]}"
```

    Last exit code: 0
    Pipeline exit codes: 1 0

## Traps and signal handling

The `trap` command lets you execute commands when a script receives a
signal or exits. This is commonly used for cleanup tasks like removing
temporary files.

``` bash
#!/usr/bin/env bash
set -euo pipefail

tmpfile=$(mktemp)
trap "rm -f ${tmpfile}" EXIT

echo "Working with ${tmpfile}"
# the temp file will be automatically removed when the script exits
```

Common signals to trap:

- `EXIT` - when the script exits (for any reason)
- `SIGINT` - when the user presses Ctrl+C
- `SIGTERM` - when the script is terminated
- `ERR` - when a command fails (with `set -e`)

You can trap multiple signals.

``` bash
#!/usr/bin/env bash
set -euo pipefail

tmpdir=$(mktemp -d)

cleanup(){
  >&2 echo "Cleaning up ${tmpdir}"
  rm -rf "${tmpdir}"
}

trap cleanup EXIT SIGINT SIGTERM

# the cleanup function runs automatically on exit
echo "Temporary directory: ${tmpdir}"
```

See `script/trap.sh` in this repository for a working example.

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
