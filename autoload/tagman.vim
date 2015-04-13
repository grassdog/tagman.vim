
if !exists("g:loaded_tagman") || &cp || v:version < 700
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

" Utils {{{

function! s:find_project_root()
  let project_root = fnamemodify(".", ":p:h")

  if !empty(g:tagman_tag_directories)
    let root_found = 0

    let candidate = fnamemodify(project_root, ":p:h")
    let last_candidate = ""

    while candidate != last_candidate
      for tags_dir in g:tagman_tag_directories
        let tags_dir_path = candidate . "/" . tags_dir
        if filereadable(tags_dir_path) || isdirectory(tags_dir_path)
          let root_found = 1
          break
        endif
      endfor

      if root_found
        let project_root = candidate
        break
      endif

      let last_candidate = candidate
      let candidate = fnamemodify(candidate, ":p:h:h")
    endwhile

    return root_found ? project_root : fnamemodify(".", ":p:h")
  endif

  return project_root
endfunction

function! s:execute_async_command(command)
  silent! exe '!' . a:command . ' &'
endfun

" }}}

" Setting tag files {{{

let s:library_tag_file_name = "lib.tags"
let s:main_tag_file_name = "tags"

let s:tags_directory = "."
let s:main_tag_file = ""
let s:lib_tag_file = ""

function! tagman#add_main_tag_path()

  let old_cwd = fnamemodify(".", ":p:h")

  let project_root = s:find_project_root()
  silent! exe "cd " . project_root

  call s:set_tag_files()

  call s:add_main_tag_file()

  silent! exe "cd " . old_cwd
endfunction

function! s:add_main_tag_file()
  silent! exe 'set tags+=' . s:main_tag_file
endfunction

function! tagman#enable_library_tags()
  silent! exe 'set tags+=' . s:lib_tag_file
endfunction

function! tagman#disable_library_tags()
  silent! exe 'set tags-=' . s:lib_tag_file
endfunction

function! tagman#list_tag_files()
  echo join(split(&tags, ","), "\n")
endfunction

function! s:set_tag_files()
  for tags_dir in g:tagman_tag_directories
    if isdirectory(tags_dir)
      let s:tags_directory = tags_dir
      break
    endif
  endfor

  if empty(s:tags_directory)
    let s:tags_directory = '.'
  endif

  let s:main_tag_file = s:tags_directory . '/' . s:main_tag_file_name
  let s:lib_tag_file = s:tags_directory . '/' . s:library_tag_file_name
endfunction

" }}}


" Building tag files {{{

let s:ctags_command = "{CTAGS} -R {OPTIONS} {DIRECTORY} 2>/dev/null"


let s:ignore_file_comment_pattern = '^[#"]'

" This expects s:tags_directory to already be set and correct
function! s:main_ctag_options()
  let options = ['--tag-relative', '--fields=+l']

  let s:files_to_include = []

  " Exclude ignored files and directories (also handle negated patterns (!))
  for ignore_file in g:tagman_ignore_files
    if filereadable(ignore_file)
      for line in readfile(ignore_file)
        if match(line, '^!') != -1
          call add(s:files_to_include, substitute(substitute(line, '^!', '', ''), '^/', '', ''))
        elseif strlen(line) > 1 && match(line, s:ignore_file_comment_pattern) == -1
          call add(options, '--exclude=' . shellescape(substitute(line, '^/', '', '')))
        endif
      endfor
    endif
  endfor

  for ignore_path in g:tagman_ignores
    call add(options, '--exclude=' . shellescape(ignore_path))
  endfor

  call add(options, '-f ' . s:main_tag_file)

  " Append files from negated patterns
  for file_to_include in s:files_to_include
    call add(options, shellescape(file_to_include))
  endfor

  return join(options, ' ')
endfunction


function! tagman#build_tags(bang)
  let old_cwd = fnamemodify(".", ":p:h")

  let project_root = s:find_project_root()
  silent! exe "cd " . project_root

  call s:set_tag_files()

  call s:add_main_tag_file()

  " Truncate/create tags file
  if a:bang
    call writefile([], s:main_tag_file, 'b')
  endif

  if !filereadable(s:main_tag_file)
    "Nothing to do for tagger. Exiting.

    silent! exe "cd " . old_cwd
    return
  endif

  let options = s:main_ctag_options()

  call s:execute_async_command(g:tagman_ctags_binary . " -R " . options . " . 2>/dev/null")

  silent! exe "cd " . old_cwd
endfunction

function! tagman#build_library_tags()
  let old_cwd = fnamemodify(".", ":p:h")

  let project_root = s:find_project_root()
  silent! exe "cd " . project_root

  call s:set_tag_files()

  call s:add_main_tag_file()

  " Truncate/create tags file
  call writefile([], s:lib_tag_file, 'b')

  if !filereadable(s:lib_tag_file)
    "Nothing to do for tagger. Exiting.

    silent! exe "cd " . old_cwd
    return
  endif

  call s:execute_async_command(g:tagman_ctags_binary . " -R --fields=+l -f " . s:lib_tag_file . " " . g:tagman_library_tag_paths . " 2>/dev/null")

  silent! exe "cd " . old_cwd
endfunction

" }}}



let &cpo = s:save_cpo
