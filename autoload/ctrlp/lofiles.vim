" To load this extension into ctrlp, add this to your vimrc:
"
"     let g:ctrlp_extensions = ['lofiles']
"
" Where 'lofiles' is the name of the file 'lofiles.vim'
"
" For multiple extensions:
"
"     let g:ctrlp_extensions = [
"         \ 'my_extension',
"         \ 'my_other_extension',
"         \ ]
echom "Loading..."

" Load guard
if ( exists('g:loaded_ctrlp_lofiles') && g:loaded_ctrlp_lofiles )
	\ || v:version < 700 || &cp
	finish
endif
let g:loaded_ctrlp_lofiles = 1

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
	\ 'init':      'ctrlp#lofiles#init()',
	\ 'accept':    'ctrlp#lofiles#accept',
	\ 'lname':     'lgame sme tool, my lowner files,search owner by input file',
	\ 'sname':     'lofiles',
	\ 'type':      'line',
	\ 'enter':     'ctrlp#lofiles#enter()',
	\ 'exit':      'ctrlp#lofiles#exit()',
	\ 'opts':      'ctrlp#lofiles#opts()',
	\ 'sort':      0,
	\ 'specinput': 0,
	\ })


" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#lofiles#init()
  return ctrlp#mylowner#lgameownersimplefiles()
endfunction

" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
function! ctrlp#lofiles#accept(mode, str)
	" For this example, just exit ctrlp and run help
	call ctrlp#exit()

  let s:out='.lofiles.out'
  let file_content=[]
  call add(file_content,"Search FileName:".a:str)
  call add(file_content,"")
  call add(file_content,"")

  let module_en_us=ctrlp#mylowner#getmodule_en_us_by_file(a:str)
  let module_simpleinfo=ctrlp#mylowner#lgameowner_get_module(module_en_us,1)
  call extend(file_content,module_simpleinfo)
  call writefile(file_content,s:out,"sb")
  call ctrlp#mybase#ctrlp_open_new_win(s:out,1)
endfunction

" (optional) Do something before enterting ctrlp
function! ctrlp#lofiles#enter()
endfunction


" (optional) Do something after exiting ctrlp
function! ctrlp#lofiles#exit()
endfunction


" (optional) Set or check for user options specific to this extension
function! ctrlp#lofiles#opts()
endfunction


" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

" Allow it to be called later
function! ctrlp#lofiles#id()
	return s:id
endfunction


" Create a command to directly call the new search type
"
" Put this in vimrc or plugin/lofiles.vim
" command! CtrlPSample call ctrlp#init(ctrlp#lofiles#id())


" vim:nofen:fdl=0:ts=2:sw=2:sts=2
