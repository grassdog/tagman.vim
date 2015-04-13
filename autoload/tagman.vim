
if !exists("g:loaded_tagman") || &cp || v:version < 700
  finish
endif

let s:save_cpo = &cpo
set cpo&vim


function! tagman#enable_library_tags()
  set tags+=.git/tags.lib
endfunction

function! tagman#disable_library_tags()
  set tags-=.git/tags.lib
endfunction


function! tagman#list_tag_files()
  echo join(split(&tags, ","), "\n")
endfunction

function! tagman#build_tags()
  " TODO Build tags
  "call tagman#build_tags()
endfunction

function! tagman#build_library_tags(master,count,bang)
  " TODO Build tags using library paths
endfunction



let &cpo = s:save_cpo
