let s:pattern = '\s\+$'

function! s:cleanable() abort
  return buflisted(bufnr('%')) && empty(&buftype)
endfunction

function! s:get_diff_lines() abort
  if &readonly || !&modifiable || !empty(&buftype)
    return []
  endif

  " Handle cases where the file is empty or cannot be read
  let l:buf_file = expand('%')
  if empty(bufname('%')) || !filereadable(l:buf_file)
    return [[1, line('$')]]
  endif

  " Only proceed if `diff` is an available command
  if executable('diff')
    let l:diffcmd = 'diff -U0 "%s" "%s"'
  else
    return []
  endif

  " This check is done before the file is written, so the buffer contents
  " needs to be compared with what's already written.
  "" Create a new file named <buffer_path>/.wstrip.<buffer_name>
  let l:tmpfile = printf('%s/.wstrip.%s', fnamemodify(l:buf_file, ':h'),
        \ fnamemodify(l:buf_file, ':t'))
  call writefile(getline(1, '$'), l:tmpfile)
  "" store the results of the diff in l:difflines
  let l:difflines = split(system(printf(l:diffcmd, l:buf_file, l:tmpfile)), "\n")
  call delete(l:tmpfile)

  " handle the case where executing l:diffcmd returns an error
  if v:shell_error
    return [[1, line('$')]]
  endif

  let l:groups = []

  for l:line in l:difflines
    if l:line !~# '^@@'
      continue
    endif

    " only added lines are of interest;
	" changed lines show as both deletion *and* addition
    let l:added = matchstr(l:line, '+\zs[0-9,]\+')
    if l:added =~# ','
      let l:parts = map(split(l:added, ','), 'str2nr(v:val)')
      if !l:parts[1]
        continue
      endif
      let l:start_line = l:parts[0]
      let l:end_line = l:parts[0] + (l:parts[1] - 1)
    else
      let l:start_line = str2nr(l:added)
      let l:end_line = l:start_line
    endif
    call add(l:groups, [l:start_line, l:end_line])
  endfor

  return l:groups
endfunction

function! wstrip#clean() abort
  if !s:cleanable()
    return
  endif

  let l:wspattern = s:pattern

  if exists('b:wstrip_trailing_max')
    let l:wspattern = '\s\{'.b:wstrip_trailing_max.'}\zs'.l:wspattern
  endif

  let l:view = winsaveview()
  for l:group in s:get_diff_lines()
    execute join(l:group, ',').'s/'.l:wspattern.'//e'
  endfor
  call histdel('search', -1)
  let @/ = histget('search', -1)
  call winrestview(l:view)
endfunction

function! wstrip#auto() abort
  if get(b:, 'wstrip_auto', get(g:, 'wstrip_auto', 0))
    call wstrip#clean()
  endif
endfunction

function! wstrip#syntax() abort
  if s:cleanable() && get(b:, 'wstrip_highlight', get(g:, 'wstrip_highlight', 1))
    let l:wspattern = s:pattern
    if exists('b:wstrip_trailing_max')
      let l:wspattern = '/\s\{'.b:wstrip_trailing_max.'}'.l:wspattern.'/ms=s+'.b:wstrip_trailing_max
    else
      let l:wspattern = '/'.l:wspattern.'/'
    endif

    execute 'syntax match WStripTrailing '.l:wspattern.' containedin=ALL'
  endif
endfunction
