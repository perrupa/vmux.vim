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
  let l:formatted = substitute(a:string, "\n", "", "g")
  return l:formatted
endfunction

function! QuoteWrap(string)
  return '"' . a:string . '"'
endfunction

function! GetKey(string)
  return QuoteWrap( SanitizeCommand(a:string) )
endfunction




" Functions
function! SendCommandToPane(cmd, target)
  let l:target = SanitizeCommand(a:target)
  let l:command = QuoteWrap(a:cmd)
  let l:dispatch = join([ s:tmux_command, "send-keys -t" . l:target, l:command, " Enter" ], ' ')
  return system(l:dispatch)
endfunction

function! RunCommand(cmd, pane_type)
  let l:id = GetPane(a:cmd, a:pane_type)
  call SendCommandToPane(a:cmd, l:id)
endfunction

function! GetPane(cmd, tmux_command)
  let s:key = GetKey(a:cmd)
  let l:pane_id = CreateShell(s:key, a:tmux_command)
  let g:vmux_panes[s:key] = l:pane_id
  return StripWhitespace( l:pane_id )
endfunction

function! CreateShell(key, tmux_pane_command)
  let l:options =  join([s:create_in_background, s:print_pane_id], ' ')
  let l:tmux_pane_command = SanitizeCommand(a:tmux_pane_command)
  let l:full_command = join([ s:tmux_command, l:tmux_pane_command, l:options ], ' ')

  let l:raw_pane_identifier = system(l:full_command)
  let l:pane_identifier = StripWhitespace(l:raw_pane_identifier)

  return l:pane_identifier
endfunction

function! RunWindow(cmd)
  return RunCommand(a:cmd, 'new-window')
endfunction

function! RunSplit(cmd)
  return RunCommand(a:cmd, 'split')
endfunction



" Aliases
" nnoremap <leader>cs :call CreateShell('clear && ls -al', 'split -h')<CR>

" Commands
command! -nargs=1 RunWindow :call RunWindow(<args>)<CR>
command! -nargs=1 RunSplit :call RunSplit(<args>)<CR>

" Desired aliases
nnoremap <silent> <leader>vh :call RunWindow('ls -l')<CR>
nnoremap <silent> <leader>vs :call RunSplit('ls -l')<CR>
" nnoremap <leader>vv :call RunVSplit('echo test')<CR>
" nnoremap <leader>vw :call RunWindow('echo test')<CR>

