"==============================================================================
" Description: global plugin for lawrencechi
" Author:      lawrencechi <codeforfuture <at> 126.com>
" Last Change: 2022.10.30
" License:     This file is placed in the public domain.
" Version:     1.0.0
"==============================================================================

" To load this extension into ctrlp, add this to your vimrc:
"
"     let g:ctrlp_extensions = ['fixtag']
"
" Where 'fixtag' is the name of the file 'fixtag.vim'
"
" For multiple extensions:
"
"     let g:ctrlp_extensions = [
"         \ 'my_extension',
"         \ 'my_other_extension',
"         \ ]
echom "Loading..."

" Load guard
if ( exists('g:loaded_ctrlp_fixtag') && g:loaded_ctrlp_fixtag )
	\ || v:version < 700 || &cp
	finish
endif
let g:loaded_ctrlp_fixtag = 1
let s:plugin_path = escape(expand('<sfile>:p:h'), '\')

" Add this extension's settings to g:ctrlp_ext_vars
"
" Required:
"
" + init: the name of the input function including the brackets and any
"         arguments
"
" + accept: the name of the action function (only the name)
"
" + lname & sname: the long and short names to use for the statusline
"
" + type: the matching type
"   - line : match full line
"   - path : match full line like a file or a directory path
"   - tabs : match until first tab character
"   - tabe : match until last tab character
"
" Optional:
"
" + enter: the name of the function to be called before starting ctrlp
"
" + exit: the name of the function to be called after closing ctrlp
"
" + opts: the name of the option handling function called when initialize
"
" + sort: disable sorting (enabled by default when omitted)
"
" + specinput: enable special inputs '..' and '@cd' (disabled by default)
"
call add(g:ctrlp_ext_vars, {
	\ 'init':      'ctrlp#fixtag#init()',
	\ 'accept':    'ctrlp#fixtag#accept',
	\ 'lname':     'serverid search',
	\ 'sname':     'fixtag',
	\ 'type':      'line',
	\ 'enter':     'ctrlp#fixtag#enter()',
	\ 'exit':      'ctrlp#fixtag#exit()',
	\ 'opts':      'ctrlp#fixtag#opts()',
	\ 'sort':      0,
	\ 'specinput': 0,
	\ })


" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#fixtag#init()
  return tagfiles()
endfunction

" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
function! ctrlp#fixtag#accept(mode, str)
	" For this example, just exit ctrlp and run help
	call ctrlp#exit()

  for tagfile in tagfiles()
    if tagfile == a:str
      let str=':!'.s:plugin_path.'/mytag_helper/mytag_helper.exe -t '.tagfile.' -r'
      silent execute str
    endif
  endfor
endfunction

" (optional) Do something before enterting ctrlp
function! ctrlp#fixtag#enter()
endfunction


" (optional) Do something after exiting ctrlp
function! ctrlp#fixtag#exit()
endfunction


" (optional) Set or check for user options specific to this extension
function! ctrlp#fixtag#opts()
endfunction


" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

" Allow it to be called later
function! ctrlp#fixtag#id()
	return s:id
endfunction


" Create a command to directly call the new search type
"
" Put this in vimrc or plugin/fixtag.vim
" command! CtrlPSample call ctrlp#init(ctrlp#fixtag#id())


" vim:nofen:fdl=0:ts=2:sw=2:sts=2
