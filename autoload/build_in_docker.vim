" ============================================================================
" File:        build-in-docker.vim
" Description: Vim plugin to build stuff in docker.
" Maintainer:  Matteo Valdina <matteo.valdina@gmail.com>
" License:     MIT
" Notes:      
" 
" ============================================================================


"{{{ Init

if v:version < '800'
  function! s:DidNotLoad()
    echohl WarningMsg|echomsg "vim-build-in-docker unavailable: requires Vim 8.0+"|echohl None
  endfunction
  command! -nargs=* RunInDocker call s:DidNotLoad()
  finish
endif

" TODO: Check docker is available.

if !exists('g:build_in_docker_debug')"{{{
  " Default debug in VERSION 0.0.1
  let g:build_in_docker_debug = 1
endif"}}}

" TODO: Additional host.
if !exists('g:build_in_docker_add_hosts')
  let g:build_in_docker_add_hosts = ''
endif

" TODO: Additional volumes.
if !exists('g:build_in_docker_volumes')
  let g:build_in_docker_volumes = ''
endif

" TODO: Check for AsyncRun plugins.

let s:plugin_path = escape(expand('<sfile>:p:h'), '\')
"}}}

"{{{ platform dependent functions.

" TODO: Get user id (*nix).
function! s:GetUserID()
  "return 1000
  let l:output = system('id -u')
  " Filter only numbers (id -u will returns also \n).
  return matchstr(l:output,'[0-9]*')
endfunction

"}}}

"{{{ path manipulation functions

function! s:PathJoin(a, b)
  " TODO: Add windows
  " TODO: Check i there is a /
  return a:a . '/' . a:b
endfunction


"}}}

"{{{ build-in-docker utility functions



function! s:SearchRoot(basepath, filter)
  " Split in tokens
  let l:tokens = split(a:basepath, '/')
  let l:base = ''
  for el in l:tokens
    let l:base = s:PathJoin(l:base, el)
    for f in a:filter
      let l:candidate = s:PathJoin(l:base, f)
      echom 'Testing ' . l:candidate
      if isdirectory(l:candidate)
        return l:base
      elseif filereadable(l:candidate)
        return l:base
      endif
    endfor
  endfor
  return a:basepath
endfunction

function! s:GetWorkingDir(opts)
  let l:base = expand('<sfile>:p:h')
  let l:optsCount = len(a:opts)
  " No options
  if l:optsCount == 0
    let l:base = s:SearchRoot(l:base, ['.git', '.hg', '.svn', 'CMakeList.txt', 'configure'])
  elseif l:optsCount == 1
    if a:opts[0] == '-cmd=<root>'
      let l:base = s:SearchRoot(l:base, ['.git', '.hg', '.svn', 'CMakeList.txt', 'configure'])
    elseif a:opts[0] == '-cmd=<file>'
      let l:base = expand('%:p:h')
    elseif a:opts[0] == '-cmd=<cwd>'
      let l:base = getcwd()
    elseif a:opts[0] =~ '-cmd=.*'
      let l:base = strpart(a:opts[0], 5)
    endif
  else
    echom "Arghh !!! This is not implemented."
  endif
  return l:base
endfunction


function! s:GetDockerAddHosts()
  " Split arguments
  if (strlen(g:build_in_docker_add_hosts) == 0)
    return ''
  endif
  let l:tokens = split(g:build_in_docker_add_hosts)
  return '--add-host="' . join(l:tokens, '" --add-host="') . '"'
endfunction


function! s:GetDockerVolumes()
  if (strlen(g:build_in_docker_volumes) == 0)
    return ''
  endif
  let l:tokens = split(g:build_in_docker_volumes)
  return '--volume="' . join(l:tokens, '" --volume="') . '"'
endfunction

function! s:DockerCmdLine(container, pwd, uid)
  let l:cmdX = 'docker run --rm -u ' . a:uid . ' --volume "' . a:pwd . ':' . a:pwd . '"'
  " TODO: Add g:hosts and volumes.
  let l:cmd = join([l:cmdX, s:GetDockerAddHosts(), s:GetDockerVolumes()], ' ')
  let l:cmd = l:cmd . ' -w "' . a:pwd . '" ' . a:container . ' '
  return l:cmd
endfunction

function! s:RunInDocker(opts, container, command)
  let l:uid = s:GetUserID()
  let l:dockerPart = s:DockerCmdLine(a:container, s:GetWorkingDir(a:opts), l:uid)
  let l:cmd = l:dockerPart . a:command
  echom l:cmd
  if exists('*asyncrun#run')
    call asyncrun#run(' ', '',  l:cmd)
  else
    execute '!' . l:cmd
  endif
endfunction

function! s:PoppingArgumentsOpts(list)
  let l:opts = []
  let l:idx = 0
  for el in a:list
    if el =~ '^-cmd=.*'
      call add(l:opts, el)
    elseif el =~ '^-perego=.*'
      call add(l:opts, el)
    else
      break
    endif
    let l:idx = l:idx + 1 
  endfor
  return [ l:opts, a:list[l:idx:] ]
endfunction

function! s:PoppingArgumentsContainer(opts, list)
  return [ a:opts, a:list[0], a:list[1:] ]
endfunction

function! s:PoppingArgumentsCommand(opts, container, list)
  return [ a:opts, a:container, join(a:list, ' ') ]
endfunction

"{{{ Misc

function! build_in_docker#RunInDocker(...) "{{{
  " Pop options, container, commands.
  let l:args = s:PoppingArgumentsOpts(a:000)
  let l:args = s:PoppingArgumentsContainer(l:args[0], l:args[1])
  let l:args = s:PoppingArgumentsCommand(l:args[0], l:args[1], l:args[2])
  echom 'Run in docker opts: [' . join(l:args[0], ', ') . '] container: ' . l:args[1] . ' command: ' . l:args[2]
  call s:RunInDocker(l:args[0], l:args[1], l:args[2])
endfunction "}}}

"}}}
