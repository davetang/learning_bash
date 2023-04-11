# Bash

Bash notes.

## Strict mode

Notes adapted and expanded from [Better Bash Scripting in 15
Minutes](https://robertmuth.blogspot.com/2012/08/better-bash-scripting-in-15-minutes.html).

Starting Bash scripts with the following:

```bash
#!/usr/bin/env bash
set -o nounset
set -o errexit
```

will deal with two very common errors:

1. Referencing undefined variables, which defaults to ''
2. Ignoring failing commands

They are the same as `-u` and `-e`, which you may be familiar with when using
the unofficial Bash strict mode `set -euo pipefail`. The longer versions are
more readable and therefore may be more preferable.

Sometimes you do not want a script to exit when a command fails and this can be
achieved by using the following idiom:

```bash
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

```bash
function_name(){
}
```

When passing arguments to Bash functions:

* The passed parameters are `$1`, `$2`, `$3`, ...,  $n, corresponding to the
  position of the parameter after the function's name.
* The `$0` variable is reserved for the function's name.
* The `$#` variable holds the number of positional parameters/arguments passed
  to the function.
* The `$*` and `$@` variables hold all positional parameters/arguments passed
  to the function.
* When double-quoted, `"$*"` expands to a **single string** separated by space
  (or what IFS is set to) - "$1 $2 $n".
* When double-quoted, `"$@"` expands to separate strings - "$1" "$2" "$n".
* When not double-quoted, `$*` and `$@` are the same.

Bash lets you define functions that behave like other commands.

```console
extract_comment(){
  grep "^#"
}

cat script/ignore_exit_code.sh | extract_comment
#!/usr/bin/env bash
# the grep command will cause the script to exit because grep returns an exit
# code > 0 when it has no matches
# grep nothing README.md
# use the following to ignore a "failing" command

comments=$(extract_comment < script/ignore_exit_code.sh)
echo ${comments}
#!/usr/bin/env bash # the grep command will cause the script to exit because grep returns an exit # code > 0 when it has no matches # grep nothing README.md # use the following to ignore a "failing" command
```

Function to sum numbers (one per line) in a file. Local scope is achieved using
`local`, which means that the variable is only visible within a block of code,
i.e. the function.

```console
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
# 15

rm num.txt
```

A classic logger that makes use of `$@`, which contains all arguments passed to
the function.

```console
log(){
   local prefix="[$(date +%Y/%m/%d\ %H:%M:%S)]: "
   >&2 echo "${prefix} $@"
} 
log "INFO" "a message"
# [2023/04/11 11:43:45]:  INFO a message
```

## Variables

Use `local` to set local scoping for variables. Use `readonly` to set immutable
variables.

```console
x=3
echo ${x}
# 3

readonly x=1984
echo ${x}
# 1984

x=2023
# bash: x: readonly variable
```

Note that you cannot `unset` a readonly variable; it exists until the shell
exits.

Assign variable or output an error, which is a useful shortcut to check whether
an argument was passed to a function.

```bash
say(){
   smt=${1?Error: missing input}
   echo ${smt}
}

say
# bash: 1: Error: missing input

# this exits with a code of 1
echo $?
# 1

say meow
# meow
```

You can also set a default value, instead exiting with an error.

```bash
say2(){
   smt=${1:-something}
   echo ${smt}
}

say2
# something

say2 nothing
# nothing
```

### Built-in variables

Some useful built-in variables.

* `$0` - name of the script
* `$n` - positional parameters to script/function
* `$$` - PID of the script
* `$!` - PID of the last command executed (and run in the background)
* `$?` - exit status of the last command  (`${PIPESTATUS}` for pipelined commands)
* `$#` - number of parameters to script/function
* `$@` - all parameters to script/function (sees arguments as separate word)
* `$*` - all parameters to script/function (sees arguments as single word)

## Regular expressions and globbing

Globbing is a method for creating patterns that is used for matching; use `==`
for string matching with globbing.

```console
t="abc123"

# returns true (globbing)
[[ "$t" == abc* ]] && echo True
# True

# returns false (literal matching)
[[ "$t" == "abc*" ]] || echo False
# False
```

Use `=~` for regular expression matching, which is only supported using double
brackets.

```console
# true (regular expression)
[[ "$t" =~ [abc]+[123]+ ]] && echo True
# True

# false (literal matching)
[[ "$t" =~ "abc*" ]] || echo False
# False
```

## String manipulation

Length of a string.

```console
#  12345678901234567890
f="path1/path2/file.ext"  
echo ${#f}
# 20
```

Slicing syntax: `${<var>:<start>}` or `${<var>:<start>:<length>}` where the
position is 0-based.

```console
f="path1/path2/file.ext"
# start from position 6
echo ${f:6}
# path2/file.ext

# start from position 6, and output 5 characters
echo ${f:6:5}
# path2

# negative index; note the space before "-"
echo "${f: -8}"
# file.ext
```

Single substitution with globbing.

```console
f="path1/path2/file.ext"
echo ${f/path?/path3}
# path3/path2/file.ext
```

Global substitution with globbing.

```console
f="path1/path2/file.ext"
echo ${f//path?/path3}
# path3/path3/file.ext
```

Splitting.

```console
f="path1/path2/file.ext"
sep="/"
array=(${f//${sep}/ })
echo ${array[@]}
# path1 path2 file.ext
```

Deletion with globbing.

```console
f="path1/path2/file.ext" 
echo ${f#*.}
# ext

# non-greedy deletion at start of string
echo ${f#*/}
# path2/file.ext

# greedy deletion at start of string
echo ${f##*/}
# file.ext

# deletion at string end
echo ${f%/*}
# path1/path2

# greedy deletion at end
echo ${f%%/*}
# path1
```

## Debugging

To perform a syntax check/dry run of a Bash script:

```bash
bash -n script/ignore_exit_code.sh
```

To produce a trace of every command executed run:

```bash
bash -v script/ignore_exit_code.sh
```

To produce a trace of the expanded command use:

```bash
bash -x script/ignore_exit_code.sh
```

`-v` and `-x` can also be made permanent by adding `set -o verbose` and `set -o
xtrace` to the script.

## Tips

* Use `$()` instead of backticks ```` because it is easier to specify and see
nested subshells using `$()`.
* Use `[[]]` (double brackets) over `[]` because it offers syntactical
  improvements and new functionality
    * `||` - logical or (double brackets only)
    * `&&` - logical and (double brackets only)
    * `<` - string comparison (no escaping necessary within double brackets)
    * `=` - string matching with globbing
    * `==` - string matching with globbing (double brackets only)
    * `=~` - string matching with regular expressions (double brackets only)
    * `-n` - string is non-empty        
    * `-z` - string is empty
    * `-eq` - numerical equality
    * `-lt` - numerical comparison
    * `-ne` - numerical inequality
* Avoid temporary files by using the `<()` operator, which transforms a command
into something that can be used as a filename, e.g. `diff <(wget -O - URL1) <(wget -O - URL2)`.
* Heredocs are handy for passing multi-line strings to a command.

```console
var=test
# variable interpolation
cat << EOF
one
${var}
three
EOF

# no variable interpolation
cat << 'EOF'
one
${var}
three
EOF
```

## Further reading

* [Advanced Bash scripting guide](https://tldp.org/LDP/abs/html/)
* [Bash reference manual](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html)
