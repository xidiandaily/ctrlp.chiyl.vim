" To load this extension into ctrlp, add this to your vimrc:
"
"     let g:ctrlp_extensions = ['loname']
"
" Where 'loname' is the name of the file 'loname.vim'
"
" For multiple extensions:
"
"     let g:ctrlp_extensions = [
"         \ 'my_extension',
"         \ 'my_other_extension',
"         \ ]
echom "Loading..."


"只有特性文件夹才加载这个功能
let s:filename=getcwd().'/protocol\star_cs.xml'
if filereadable(s:filename) == 0
	finish
endif

" Load guard
if ( exists('g:loaded_ctrlp_loname') && g:loaded_ctrlp_loname )
	\ || v:version < 700 || &cp
	finish
endif
let g:loaded_ctrlp_loname = 1

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
	\ 'init':      'ctrlp#loname#init()',
	\ 'accept':    'ctrlp#loname#accept',
	\ 'lname':     'lgame sme tool, my lowner ,search owner by module name',
	\ 'sname':     'loname',
	\ 'type':      'line',
	\ 'enter':     'ctrlp#loname#enter()',
	\ 'exit':      'ctrlp#loname#exit()',
	\ 'opts':      'ctrlp#loname#opts()',
	\ 'sort':      0,
	\ 'specinput': 0,
	\ })


" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#loname#init()
  return ctrlp#mylowner#namelists()
endfunction

" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
function! ctrlp#loname#accept(mode, str)
	" For this example, just exit ctrlp and run help
	call ctrlp#exit()

  let s:out='.loname.out'
  let file_content=[]
  call add(file_content,"Search Member:".a:str)
  call add(file_content,"")
  call add(file_content,"")

  let module_simpleinfo=ctrlp#mylowner#lgameowner_get_module(a:str,1)
  call extend(file_content,module_simpleinfo)
  call writefile(file_content,s:out,"sb")
  call ctrlp#mybase#ctrlp_open_new_win(s:out,1)
endfunction

" (optional) Do something before enterting ctrlp
function! ctrlp#loname#enter()
endfunction


" (optional) Do something after exiting ctrlp
function! ctrlp#loname#exit()
endfunction


" (optional) Set or check for user options specific to this extension
function! ctrlp#loname#opts()
endfunction


" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

" Allow it to be called later
function! ctrlp#loname#id()
	return s:id
endfunction


" Create a command to directly call the new search type
"
" Put this in vimrc or plugin/loname.vim
" command! CtrlPSample call ctrlp#init(ctrlp#loname#id())


" vim:nofen:fdl=0:ts=2:sw=2:sts=2
