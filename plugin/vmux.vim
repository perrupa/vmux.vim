" Contants
let s:log_count = 1
let s:tmux_command = "tmux"
let s:create_in_background = '-d'
let s:print_pane_id = '-P'
let g:vmux_panes = {}


" Helper functions
function! LogDebug(key, value)
  return
  echo "\n"
  echo s:log_count . ": " . a:key . " = \"" . a:value . "\""
  echo "\n"
  let s:log_count = s:log_count + 1
endfunction

function! SanitizeCommand(cmd)
  return a:cmd " escape(a:cmd, '%\"$`')
endfunction

function! StripWhitespace(string)
  call LogDebug("pre-format", a:string)
  let l:formatted = substitute(a:string, "\n", "", "g")
  call LogDebug("post-format", l:formatted)
  return l:formatted
endfunction

function! QuoteWrap(string)
  return '"' . a:string . '"'
endfunction

function! GetKey(string)
  return QuoteWrap( SanitizeCommand(a:string) )
endfunction




" Functions
function! CallCommand(cmd, target)
  let l:target = SanitizeCommand(a:target)
  let l:command = QuoteWrap(a:cmd)
  let l:dispatch = join([ s:tmux_command, "send-keys -t" . l:target, l:command, " Enter" ], ' ')

  call LogDebug("dispatch", l:dispatch)

  return system(l:dispatch)
endfunction

function! GetPane(cmd, tmux_command)
  let s:key = GetKey(a:cmd)
  call LogDebug("key", s:key)
  let l:pane_id = CreateShell(s:key, a:tmux_command)
  call LogDebug("pane_id", l:pane_id)
  let g:vmux_panes[s:key] = l:pane_id
  return l:pane_id
endfunction

function! CreateShell(key, tmux_pane_command)
  call LogDebug("key", a:key)
  let l:options =  join([s:create_in_background, s:print_pane_id], ' ')
  let l:tmux_pane_command = SanitizeCommand(a:tmux_pane_command)
  let l:full_command = join([ s:tmux_command, l:tmux_pane_command, l:options ], ' ')

  call LogDebug("full_command", l:full_command)

  let l:raw_pane_identifier = system(l:full_command)

  call LogDebug("raw_pane_identifier", l:raw_pane_identifier)
  let l:pane_identifier = StripWhitespace(l:raw_pane_identifier)

  call LogDebug("pane_identifier", l:pane_identifier)

  return l:pane_identifier
endfunction

function! RunWindow(cmd)
  let l:command = SanitizeCommand(a:cmd)
  let l:unformatted_id = GetPane(l:command, 'new-window')

  call LogDebug("unformatted_id", l:unformatted_id)

  let l:id = StripWhitespace( l:unformatted_id )

  call LogDebug("command", l:command)
  call LogDebug("unformatted_id", l:unformatted_id)
  call LogDebug("id", l:id)

  call CallCommand(l:command, l:id)
  return l:id
endfunction



" Aliases
" nnoremap <leader>cs :call CreateShell('clear && ls -al', 'split -h')<CR>

" Commands
command! -nargs=1 RunWindow :call RunWindow(<args>)<CR>

" Desired aliases
nnoremap <silent> <leader>vh :call RunWindow('ls -l')<CR>
" nnoremap <leader>vh RunWindow('ls -l')
" nnoremap <leader>vv :call RunVSplit('echo test')<CR>
" nnoremap <leader>vw :call RunWindow('echo test')<CR>

