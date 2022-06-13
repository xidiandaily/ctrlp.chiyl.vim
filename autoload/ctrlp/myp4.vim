" To load this extension into ctrlp, add this to your vimrc:
"
"     let g:ctrlp_extensions = ['myp4']
"
" Where 'myp4' is the name of the file 'myp4.vim'
"
" For multiple extensions:
"
"     let g:ctrlp_extensions = [
"         \ 'my_extension',
"         \ 'my_other_extension',
"         \ ]
echom "Loading..."

" Load guard
if ( exists('g:loaded_ctrlp_myp4') && g:loaded_ctrlp_myp4 )
	\ || v:version < 700 || &cp
	finish
endif
let g:loaded_ctrlp_myp4 = 1

function! s:open_new_win(fileout)
    if bufexists(a:fileout)
      if len(win_findbuf(bufnr(a:fileout)))==0
        silent execute ':25sv +1 '.a:fileout
      endif
    else
      silent execute ':25sv +1 '.a:fileout
    endif
endfunction

function! ctrlp#myp4#P4Edit()
    let l:file=expand("%:p")
    silent execute ':!p4 edit '.l:file
endfunction

function! ctrlp#myp4#P4Revert()
    let l:file=expand("%:p")
    silent execute ':!p4 revert '.l:file
endfunction

function! ctrlp#myp4#P4RevertAll()
    silent execute ':!p4 revert ...'
endfunction

function! ctrlp#myp4#P4Opened()
    let l:file=expand("%:p")
    let s:out='.myp4.out.opened'
    execute ':!p4 opened >'.s:out
    call s:open_new_win(s:out)
endfunction

function! ctrlp#myp4#P4Annotate()
    let l:file=expand("%:p")
    let s:out='.myp4.out.annotate'
    execute ':!p4 annotate -c -u '.l:file.' >'.s:out
    call s:open_new_win(s:out)
endfunction

function! ctrlp#myp4#P4Change()
    let l:file=expand("%:p")
    let s:wordUnderCursor = str2nr(expand("<cword>"),10)
    if s:wordUnderCursor > 0
      let s:changenum=input('please input change num[default:'.s:wordUnderCursor.']:')
      if str2nr(s:changenum,10) == 0
        let s:changenum=s:wordUnderCursor
      endif
    else
      let s:changenum=input('please input change num[default:new]:')
    endif
    let s:out='.myp4.out.change'
    execute ':!p4 change -o '.s:changenum.' >'.s:out
    execute ':!p4 describe '.s:changenum.' >>'.s:out
    call s:open_new_win(s:out)
endfunction


function! ctrlp#myp4#P4Sync()
    let s:out='.myp4.out.sync'
    execute ':!p4 sync --parallel=0 | tee '.s:out
    call s:open_new_win(s:out)
endfunction

function! ctrlp#myp4#P4Filelog()
    let l:file=expand("%:p")
    let s:out='.myp4.out.filelog'
    execute ':!p4 filelog -l '.l:file.' > '.s:out
    call s:open_new_win(s:out)
endfunction

function! ctrlp#myp4#P4Review()
    let s:link=input('please input review link:')
    let s:output={'changenum':0}
py3 << EOF
import re
import vim

link=vim.eval('s:link')
output=vim.bindeval('s:output')
result=re.search('(\d+)',link)
if result:
  output['changenum']=int(result.group(1))
EOF
    if s:output['changenum'] > 0
      let s:out='.myp4.out.review'
      execute ':!p4 unshelve -s '.s:output['changenum'].' > '.s:out
      call s:open_new_win(s:out)
    endif
endfunction

let g:ctrlp_myp4_cmds=[]
let s:myp4_cmds =[
      \ {'name':'p4edit','cmd':'call ctrlp#myp4#P4Edit()','desc':'p4 edit'},
      \ {'name':'p4revertall','cmd':'call ctrlp#myp4#P4RevertAll()','desc':'p4 revert all'},
      \ {'name':'p4revert','cmd':'call ctrlp#myp4#P4Revert()','desc':'p4 revert'},
      \ {'name':'p4opened','cmd':'call ctrlp#myp4#P4Opened()','desc':'p4 opened '},
      \ {'name':'p4annotate','cmd':'call ctrlp#myp4#P4Annotate()','desc':'p4 files '},
      \ {'name':'p4change','cmd':'call ctrlp#myp4#P4Change()','desc':'p4 change -o'},
      \ {'name':'p4sync','cmd':'call ctrlp#myp4#P4Sync()','desc':'p4 sync --parallel=0'},
      \ {'name':'p4filelog','cmd':'call ctrlp#myp4#P4Filelog()','desc':'p4 filelog '},
      \ {'name':'p4review','cmd':'call ctrlp#myp4#P4Review()','desc':'p4 review,unshelve'},
      \]

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
	\ 'init': 'ctrlp#myp4#init()',
	\ 'accept': 'ctrlp#myp4#accept',
	\ 'lname': 'my p4 command',
	\ 'sname': 'myp4',
	\ 'type': 'line',
	\ 'enter': 'ctrlp#myp4#enter()',
	\ 'exit': 'ctrlp#myp4#exit()',
	\ 'opts': 'ctrlp#myp4#opts()',
	\ 'sort': 0,
	\ 'specinput': 0,
	\ })


" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#myp4#init()
  return map(copy(g:ctrlp_myp4_cmds)+s:myp4_cmds,
        \ 'printf("%s\t: %s", v:val.name, v:val.desc)')
endfunction

" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
function! ctrlp#myp4#accept(mode, str)
	" For this example, just exit ctrlp and run help
	call ctrlp#exit()
  let name = split(a:str, "	")[0]
  let cmds = g:ctrlp_myp4_cmds+s:myp4_cmds
  for i in cmds
    if i.name==name
      silent execute ':'.i.cmd
    endif
  endfor
endfunction

" (optional) Do something before enterting ctrlp
function! ctrlp#myp4#enter()
endfunction


" (optional) Do something after exiting ctrlp
function! ctrlp#myp4#exit()
endfunction


" (optional) Set or check for user options specific to this extension
function! ctrlp#myp4#opts()
endfunction


" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

" Allow it to be called later
function! ctrlp#myp4#id()
	return s:id
endfunction


" Create a command to directly call the new search type
"
" Put this in vimrc or plugin/myp4.vim
" command! CtrlPSample call ctrlp#init(ctrlp#myp4#id())


" vim:nofen:fdl=0:ts=2:sw=2:sts=2
