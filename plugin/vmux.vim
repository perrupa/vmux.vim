" Contants
let s:tmuxCommand = "silent !tmux"
let s:createInBackground = '-d'
let s:printPaneID = '-P'

let s:vmuxPanes = {}

" Helper functions
function! SanitizeCommand(cmd)
  return escape(a:cmd, '\"$`')
endfunction

function! QuoteWrap(string)
  return '"' . string . '"'
endfunction



" Functions
function! CallCommand(cmd, target)
  echo a:cmd
  execute s:tmuxCommand " send-keys -t".SanitizeCommand(a:target)." ".SanitizeCommand(a:cmd)." Enter"
endfunction

function! GetPane(cmd, location)
  let s:key = QuoteWrap( SanitizeCommand(a:cmd) )
endfunction

function! CreateShell(cmd, location)
  let s:options =  join([s:createInBackground, s:printPaneID], ' ')
  let s:full_command = join([s:tmuxCommand, s:command, s:options], ' ')
  let s:paneIdentifier = execute(s:full_command)
  return s:paneIdentifier
endfunction

function! RunSplit(cmd)
  let s:command = QuoteWrap( SanitizeCommand(a:cmd) )
  let s:full_command = join([s:tmuxCommand, s:command, s:options], ' ')
  let s:paneIdentifier = execute(s:full_command)
  return s:paneIdentifier
endfunction



" Aliases
nnoremap <leader>cs :call CreateShell('clear && ls -al', 'split -h')<CR>


" Desired aliases

nnoremap <leader>vh :call RunSplit('echo test')<CR>
" nnoremap <leader>vv :call RunVSplit('echo test')<CR>
" nnoremap <leader>vw :call RunWindow('echo test')<CR>

