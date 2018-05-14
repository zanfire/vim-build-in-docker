" ============================================================================
" File:        build-docker.vim
" Description: Vim plugin for run toolchain inside a docker container.
" Maintainer:  Matteo Valdina <matteo.valdina@gmail.com>
" License:     MIT
" Notes:       
"
" ============================================================================


"{{{ Init
if !exists('g:build_in_docker_debug') && (exists('g:build_in_docker_disable') || exists('loaded_build_in_docker') || &cp)"{{{
    finish
endif
let loaded_build_in_docker = 1"}}}
"}}}

"{{{ Exported command.

command! -nargs=* RunInDocker call build_in_docker#RunInDocker(<f-args>)
command! -nargs=0 CMakeInDocker call build_in_docker#CMakeInDocker()

"}}}
