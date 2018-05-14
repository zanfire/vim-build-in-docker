" ============================================================================
" File:        build-in-docker.vim
" Description: Vim plugin to build stuff in docker.
" Maintainer:  Matteo Valdina <matteo.valdina@gmail.com>
" License:     MIT
" Notes:      
" 
" ============================================================================


"{{{ Init

if v:version < '800'"{{{
  function! s:DidNotLoad()
    echohl WarningMsg|echomsg "vim-build-in-docker unavailable: requires Vim 8.0+"|echohl None
  endfunction
  command! -nargs=* RunInDocker call s:DidNotLoad()
  finish
endif"}}}

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
  "return  substitute(l:output, '^\s*\(.\{-}\)\s*$', '\1', '')
  return matchstr(l:output,'[0-9]*')
endfunction

function! s:GetWorkingDir()
  let l:base = expand('<sfile>:p:h')
  return l:base
endfunction

"}}}

"{{{ build-in-docker utility functions
"

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
  let l:cmd = l:cmd . ' -w ' . a:pwd . ' ' . a:container . ' '
  return l:cmd
endfunction

function! s:RunInDocker(container, command)
  let l:uid = s:GetUserID()
  let l:wd = s:GetWorkingDir()
  let l:dockerPart = s:DockerCmdLine(a:container, l:wd, l:uid)
  let l:cmd = l:dockerPart . a:command
  echom l:cmd
  if exists('*asyncrun#run')
    call asyncrun#run(' ', '',  l:cmd)
  else
    execute '!' . l:cmd
  endif
endfunction


"{{{ Misc

function! build_in_docker#RunInDocker(container, command) "{{{
  call s:RunInDocker (a:container, a:command)
endfunction "}}}

"}}}
