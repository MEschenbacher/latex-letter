# new-letter.sh

The most annoying thing about manually writing letters in latex is to copy a previously
written letter to a new file (while actively having to think about the new file name),
skipping through the first lines, change a few variables before getting to start with a
subject, and continue with the letter body.

`new-letter.sh` is a command line script which asks for details and creates the letter based
on a latex template. It also keeps track of the recipients (saved in `~/.address_history`
(controlled via environment variable `LETTERHISTFILE`)) and uses dmenu to cycle through
previous recipients.

```
Usage new-letter.sh [-n] [-d DIR] [-s] [-o FILE] [-t FILE]
 -n		 does not open $EDITOR on the created file
 -d DIR		 saves the created file in DIR
 -s		 skips variables which are unlikely to change
 -o FILE	 saves the file as FILE
 -t FILE	 use FILE as template source file
```

By default `new-letter.sh` looks for the configuration at `~/.letter.conf` (controlled via
environment variable `LETTERCONFIG`) and for the latex source at `~/.letter.tex` (controlled
via environment variable `LETTERSOURCE`).

# Requirements

The script is using `/bin/bash`.

Packages `slugify`, `m4`, and `dmenu`. On Debian they are installed via `apt-get install
slugify m4 dmenu`.

# Install

- Copy `new-letter.sh` to a location to which your `$PATH` points to.
- Copy the configuration `letter.conf.example` to `~/.letter.conf` and edit with your personal
information.
- Copy the latex template `letter.tex` to `~/.letter.tex`.
