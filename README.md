# wstrip.vim

Strip trailing whitespace on changed lines.  This plugin was inspired
by [a question][1] on the Vi StackExchange.

## Summary

This plugin uses `diff` to strip whitespace from lines that you
changed while editing.  This allows you to keep newly added lines
clean without affecting the history of existing lines.

## Usage

Whitespace can be automatically stripped when writing the buffer by
setting `g:wstrip_auto` or `b:wstrip_auto` to `1`.  This is disabled
by default.

To enable globally for all filetypes, place `let g:wstrip_auto = 1` in
a location that's loaded by Vim on startup (e.g., vimrc).

To enable for a specific filetype, add `let b:wstrip_auto = 1` in the
filetype's ftplugin file.

If you don't want automatic cleaning, the `:WStrip` command can be
used to manually clean whitespace.

Trailing whitespace will be highlighted using the `WStripTrailing`
syntax group.  If it appears that Vim is capable of underlining text,
trailing whitespace will be highlighted as a red underline.
Otherwise, it will highlighted with a red background.  To disable
highlighting, set `b:wstrip_highlight` or `g:wstrip_highlight` to `0`.

If you want to allow a certain amount of trailing whitespace, you can
set `b:wstrip_trailing_max` to the maximum number of whitespace
characters that are allowed to be at the end of a line.  By default,
this is set to `2` for the `markdown` filetype.

## License

MIT

[1]: http://vi.stackexchange.com/q/7959/5229
