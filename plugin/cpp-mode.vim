if exists('g:loaded_cpp_mode') | finish | endif

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to defaults

command! CopyCppMethod lua require'cpp-mode'.copy_cpp_method()
command! PasteCppMethod lua require'cpp-mode'.paste_cpp_method()

let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_cpp_mode = 1
