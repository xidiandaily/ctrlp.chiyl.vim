" To load this extension into ctrlp, add this to your vimrc:
"
"     let g:ctrlp_extensions = ['lsvrid']
"
" Where 'lsvrid' is the name of the file 'lsvrid.vim'
"
" For multiple extensions:
"
"     let g:ctrlp_extensions = [
"         \ 'my_extension',
"         \ 'my_other_extension',
"         \ ]
echom "Loading..."

" Load guard
if ( exists('g:loaded_ctrlp_lsvrid') && g:loaded_ctrlp_lsvrid )
	\ || v:version < 700 || &cp
	finish
endif
let g:loaded_ctrlp_lsvrid = 1

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
	\ 'init':      'ctrlp#lsvrid#init()',
	\ 'accept':    'ctrlp#lsvrid#accept',
	\ 'lname':     'lgame sme tool, my lowner files,search owner by current buffer',
	\ 'sname':     'lsvrid',
	\ 'type':      'line',
	\ 'enter':     'ctrlp#lsvrid#enter()',
	\ 'exit':      'ctrlp#lsvrid#exit()',
	\ 'opts':      'ctrlp#lsvrid#opts()',
	\ 'sort':      0,
	\ 'specinput': 0,
	\ })


" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#lsvrid#init()
  let s:filename=getcwd().'/protocol/star_macro.xml'
  let s:key2line={}
  if filereadable(s:filename) == 1
    let s:filelist=readfile(s:filename)
    let keylists=[]
    let line_no=0
    for line in s:filelist
      let line_no+=1
      let retstr=matchstr(line,"<macro .*FUNC_.*/>")
      if retstr!=''
        call add(keylists,retstr)
        let s:key2line[retstr]=line_no
      endif
    endfor
    return keylists
  endif
  return []
endfunction

" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
function! ctrlp#lsvrid#accept(mode, str)
	" For this example, just exit ctrlp and run help
	call ctrlp#exit()
  let line_no=s:key2line[a:str]
  silent execute ':25sv +'.line_no.' protocol/star_macro.xml'
endfunction

" (optional) Do something before enterting ctrlp
function! ctrlp#lsvrid#enter()
endfunction


" (optional) Do something after exiting ctrlp
function! ctrlp#lsvrid#exit()
endfunction


" (optional) Set or check for user options specific to this extension
function! ctrlp#lsvrid#opts()
endfunction


" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

" Allow it to be called later
function! ctrlp#lsvrid#id()
	return s:id
endfunction


" Create a command to directly call the new search type
"
" Put this in vimrc or plugin/lsvrid.vim
" command! CtrlPSample call ctrlp#init(ctrlp#lsvrid#id())


" vim:nofen:fdl=0:ts=2:sw=2:sts=2
