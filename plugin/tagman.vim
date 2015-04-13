" tagman.vim - Manage your ctags from Vim
" Maintainer:   Ray Grasso <http://raygrasso.com>
" Version: 1.0

if exists("g:loaded_tagman") || &cp || v:version < 700
  finish
endif
let g:loaded_tagman = 100

let s:save_cpo = &cpo
set cpo&vim

" Auto generate ctags
if !exists('g:tagman_auto_generate')
  let g:tagman_auto_generate = 1
endif

if !exists("g:tagman_ctags_binary")
  let g:tagman_ctags_binary = "ctags"
endif

" Project tags
if !exists('g:tagman_project_tags_command')
  let g:tagman_project_tags_command = "{CTAGS} -R {OPTIONS} {DIRECTORY} 2>/dev/null"
endif

" Library tags
if !exists('g:tagman_library_tags_command')
  let g:tagman_library_tags_command = "{CTAGS} -R {OPTIONS} `bundle show --paths` node_modules 2>/dev/null"
endif

" Ignored files and directories list
if !exists('g:tagman_ignore_files')
  let g:tagman_ignore_files = ['.gitignore', '.svnignore', '.cvsignore']
endif

" A list of directories used as a place for tags.
if !exists('g:tagman_directories')
  let g:tagman_directories = [".git", ".hg", ".svn", ".bzr", "_darcs", "CVS"]
endif


" TODO enable or disable tags
" set tags+=.git/tags

" TODO Bind to save event
" TODO Debounce calls

augroup augrp__tagman
  autocmd!
  " autocmd BufWritePost * :call tagman#auto_ctags()
  " autocmd BufReadPost  * :call tagman#auto_settags()
augroup END

command! -bar -bang -count=0 -nargs=0 ListTagFiles :call tagman#list_tag_files()
command! -bar -bang -count=0 -nargs=0 EnableLibraryTags :call tagman#enable_library_tags()
command! -bar -bang -count=0 -nargs=0 DisableLibraryTags :call tagman#disable_library_tags()

let &cpo = s:save_cpo
