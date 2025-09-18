# Bash history expansion

The following works if history expansion is enabled; `set -H`, which is the default.

## Basic

* `!!` -> entire previous command
* `!$` -> last argument of previous command
* `!^` -> first argument of previous command
* `!*` -> all arguments of previous command

## Event designators

* `!n` -> command number `n` from `history`
* `!-n` -> the command run *n commands ago*
* `!string` -> last command starting with `string`
* `!?string?` -> last command containing `string`
* `^old^new` -> quick substitution in last command (first occurrence of `old` replaced by `new`)
* `!!:s/old/new/` -> same as above, but explicit `:s` substitution
* `!!:gs/old/new/` -> replace *all* occurrences of `old` with `new`

```console
ls README.md history.md
^ls^head # becomes head README.md history.md
```

## Word designators

These let you pick parts (words) of the matched command:

* `!$` -> last argument
* `!^` -> first argument
* `!*` -> all arguments
* `!:0` -> the command itself (the program name)
* `!:n` -> nth word (counting from 0 = the command)
* `!:n-m` -> range of words
* `!:n*` -> from nth word to the last argument
* `!!:n` -> nth word of the previous command

```console
echo alpha beta gamma delta
# output: alpha beta gamma delta
```

* `!!:0` -> `echo`
* `!!:1` -> `alpha`
* `!!:2-3` -> `beta gamma`
* `!!:1*` -> `alpha beta gamma delta`

## Modifiers

You can transform the result:

* `:p` -> print the expansion without executing it
* `:h` -> remove last path component (dirname)
* `:t` -> keep only last path component (basename)
* `:r` -> remove file extension
* `:e` -> keep only file extension
* `:q` -> quote each word
* `:x` -> like `:q`, but break into words safely

```console
ls /usr/local/bin/python3
echo !!:1:h   # expands to /usr/local/bin
echo !!:1:t   # expands to python3
```

## Useful combos

* Run last command with `sudo`:

```console
sudo !!
```

* Re-run last command but swap arguments:

```console
!!:gs/foo/bar/
```

* Use same files with a different tool:

```console
grep "main" file1.c file2.c
vim !*
```


Tip: If you're unsure what `!something` will expand to, tack on `:p` first to preview it:

```console
!!:p
```
