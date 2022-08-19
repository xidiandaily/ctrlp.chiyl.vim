" To load this extension into ctrlp, add this to your vimrc:
"
"     let g:ctrlp_extensions = ['lresource']
"
" Where 'lresource' is the name of the file 'lresource.vim'
"
" For multiple extensions:
"
"     let g:ctrlp_extensions = [
"         \ 'my_extension',
"         \ 'my_other_extension',
"         \ ]
echom "Loading..."

" Load guard
if ( exists('g:loaded_ctrlp_lresource') && g:loaded_ctrlp_lresource )
	\ || v:version < 700 || &cp
	finish
endif
let g:loaded_ctrlp_lresource = 1

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
	\ 'init':      'ctrlp#lresource#init()',
	\ 'accept':    'ctrlp#lresource#accept',
	\ 'lname':     'csmsg cmd search',
	\ 'sname':     'lresource',
	\ 'type':      'line',
	\ 'enter':     'ctrlp#lresource#enter()',
	\ 'exit':      'ctrlp#lresource#exit()',
	\ 'opts':      'ctrlp#lresource#opts()',
	\ 'sort':      0,
	\ 'specinput': 0,
	\ })


" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#lresource#init()
  let s:filename='D:\\GitBase\\myLGameTools\\lgame_resource\\lgame_resource.txt'
  let s:lresobjlist=[]

  let s:line_no=0
  for line in readfile(s:filename)
    let s:line_no+=1
    let lresobj={
          \ "content":line,
          \ "filename":s:filename,
          \ "line_no":s:line_no}
    call add(s:lresobjlist,lresobj)
  endfor

  let s:contentlist=[]
  for lresobj in s:lresobjlist
    call add(s:contentlist,lresobj['content'])
  endfor
  return s:contentlist
endfunction

" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
function! ctrlp#lresource#accept(mode, str)
	" For this example, just exit ctrlp and run help
	call ctrlp#exit()

  for lresobj in s:lresobjlist
    if a:str==lresobj['content']
      silent execute ':25sv +'.lresobj['line_no'].' '.lresobj['filename']
    endif
  endfor
endfunction

" (optional) Do something before enterting ctrlp
function! ctrlp#lresource#enter()
endfunction


" (optional) Do something after exiting ctrlp
function! ctrlp#lresource#exit()
endfunction


" (optional) Set or check for user options specific to this extension
function! ctrlp#lresource#opts()
endfunction


" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

" Allow it to be called later
function! ctrlp#lresource#id()
	return s:id
endfunction


" Create a command to directly call the new search type
"
" Put this in vimrc or plugin/lresource.vim
" command! CtrlPSample call ctrlp#init(ctrlp#lresource#id())


" vim:nofen:fdl=0:ts=2:sw=2:sts=2
