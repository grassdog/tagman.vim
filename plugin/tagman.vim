" tagman.vim - Manage your ctags from Vim
" Maintainer:   Ray Grasso <http://raygrasso.com>
" Version: 1.0

if exists("g:loaded_tagman") || &cp || v:version < 700
  finish
endif
let g:loaded_tagman = 100

let s:save_cpo = &cpo
set cpo&vim


" Settings {{{

" Auto generate ctags
if !exists('g:tagman_auto_generate')
  let g:tagman_auto_generate = 1
endif

if !exists("g:tagman_ctags_binary")
  let g:tagman_ctags_binary = "ctags"
endif

" Library tags
if !exists('g:tagman_library_tag_paths')
  let g:tagman_library_tag_paths = "`bundle show --paths` node_modules vendor"
endif

" Files that contain paths to be ignored
if !exists('g:tagman_ignore_files')
  let g:tagman_ignore_files = ['.gitignore', '.svnignore', '.cvsignore']
endif

" A list of directories used to store tags.
if !exists('g:tagman_tag_directories')
  let g:tagman_tag_directories = [".git", ".hg", ".svn", "CVS"]
endif

" Explicit paths to ignore
if !exists('g:tagman_ignores')
  let g:tagman_ignores = ['node_modules', '*vendor', '*.min.js']
endif

" }}}

call tagman#add_main_tag_path()

" TODO Debounce calls

augroup augrp__tagman
  autocmd!

  if g:tagman_auto_generate
    autocmd BufWritePost * :call tagman#build_tags(0)
  endif
augroup END

command! -count=0 -nargs=0 ListTagFiles :call tagman#list_tag_files()
command! -count=0 -nargs=0 EnableLibTags :call tagman#enable_library_tags()
command! -count=0 -nargs=0 DisableLibTags :call tagman#disable_library_tags()

command! -bang -count=0 -nargs=0 BuildTags :call tagman#build_tags(<bang>0)
command! -count=0 -nargs=0 BuildLibTags :call tagman#build_library_tags()


let &cpo = s:save_cpo
