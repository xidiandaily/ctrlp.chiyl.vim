"==============================================================================
" Description: global plugin for lawrencechi
" Author:      lawrencechi <codeforfuture <at> 126.com>
" Last Change: 2024.02.22
" License:     This file is placed in the public domain.
" Version:     1.0.0
"==============================================================================

" To load this extension into ctrlp, add this to your vimrc:
"
"     let g:ctrlp_extensions = ['mygit']
"
" Where 'mygit' is the name of the file 'mygit.vim'
"
" For multiple extensions:
"
"     let g:ctrlp_extensions = [
"         \ 'my_extension',
"         \ 'my_other_extension',
"         \ ]
echom "Loading..."

" Load guard
"if ( exists('g:loaded_ctrlp_mygit') && g:loaded_ctrlp_mygit )
"	\ || v:version < 700 || &cp
"	finish
"endif
let g:loaded_ctrlp_mygit = 1
let s:plugin_path=escape(expand("<sfile>:p:h"),'\')

if has('python3')
  execute 'py3file ' . s:plugin_path . '/p4change2singleline.py'
else
  execute 'pyfile ' . s:plugin_path . '/p4change2singleline.py'
endif

function! ctrlp#mygit#do_log(cnt,content_length)
    let s:out=tinytoolchiyl#base#gettmploopfilename#getname()
    let s:prev_win=win_getid()
    silent execute ':!git log -'.a:cnt.' --patch -U'.a:content_length.' >'.s:out
    call win_gotoid(s:prev_win)
    call ctrlp#mybase#ctrlp_open_new_win(s:out,1)
endfunction

function! ctrlp#mygit#pull()
    let s:out=tinytoolchiyl#base#gettmploopfilename#getname()
    silent execute ':!git pull 2>&1 >'.s:out
    call ctrlp#mybase#ctrlp_open_new_win(s:out,1)
    call ctrlp#mygit#do_log(1,10)
endfunction

function! ctrlp#mygit#log()
    let s:cnt=tinytoolchiyl#base#myutil#get_user_input_num('show log length from history',10)
    let s:content_length=tinytoolchiyl#base#myutil#get_user_input_num('get patch content length',3)
    call ctrlp#mygit#do_log(s:cnt,s:content_length)
endfunction

function! ctrlp#mygit#filelog()
    let l:file=expand("%:p")
    let s:cnt=tinytoolchiyl#base#myutil#get_user_input_num('show log length from history',10)
    let s:content_length=tinytoolchiyl#base#myutil#get_user_input_num('get patch content length',0)
    let s:out=tinytoolchiyl#base#gettmploopfilename#getname()
    let s:prev_win=win_getid()
    if s:content_length == 0
        silent execute ':!git log -'.s:cnt.' '.l:file.' >'.s:out
    else
        silent execute ':!git log -'.s:cnt.' --patch -U'.s:content_length.' '.l:file.' >'.s:out
    endif
    call win_gotoid(s:prev_win)
    call ctrlp#mybase#ctrlp_open_new_win(s:out,1)
endfunction

function! ctrlp#mygit#fileblame()
    let l:file=expand("%:p")
    let s:out=tinytoolchiyl#base#gettmploopfilename#getname()
    let s:prev_win=win_getid()
    silent execute ':!git blame '.l:file.' >'.s:out
    call win_gotoid(s:prev_win)
    call ctrlp#mybase#ctrlp_open_new_win(s:out,1)
endfunction

function! ctrlp#mygit#diff()
    let s:out=tinytoolchiyl#base#gettmploopfilename#getname()
    let s:prev_win=win_getid()
    let s:content_length=tinytoolchiyl#base#myutil#get_user_input_num('get diff content length',10)
    silent execute ':!echo git status -s -uno >'.s:out
    silent execute ':!git status -s -uno >>'.s:out
    silent execute ':!echo. >>'.s:out
    silent execute ':!echo ================================================================================ >>'.s:out
    silent execute ':!echo. >>'.s:out
    silent execute ':!dos2unix '.s:out
    silent execute ':!git diff -U'.s:content_length.' >>'.s:out
    silent execute ':!echo |set /p="vim:tw=78:ts=8:noet:ft=git:norl:" >>'.s:out
    call win_gotoid(s:prev_win)
    call ctrlp#mybase#ctrlp_open_new_win(s:out,1)
endfunction

function! ctrlp#mygit#show_commit_detail()
    let s:commit = tinytoolchiyl#base#myutil#get_selected_text()
    if len(s:commit) == 0
        let s:commit = tinytoolchiyl#base#myutil#get_user_input_text('input commit',getreg('*'))
    endif

    let s:content_length=tinytoolchiyl#base#myutil#get_user_input_num('get patch content length',3)
    let s:out=tinytoolchiyl#base#gettmploopfilename#getname()
    silent execute ':!git show '.s:commit.' --patch -U'.s:content_length.' >'.s:out
    call ctrlp#mybase#ctrlp_open_new_win(s:out,1)
endfunction

function! ctrlp#mygit#guicommit()
  sil execute ':!cmd.exe /c start "" "C:\Program Files\TortoiseGit\bin\TortoiseGitProc.exe" /command:commit /path:./ /closeonend:0'
endfunction

function! ctrlp#mygit#guilog()
  sil execute ':!cmd.exe /c start "" "C:\Program Files\TortoiseGit\bin\TortoiseGitProc.exe" /command:log /path:./ /closeonend:0'
endfunction

function! ctrlp#mygit#guifilelog()
  let l:file=expand("%:p")
  sil execute ':!cmd.exe /c start "" "C:\Program Files\TortoiseGit\bin\TortoiseGitProc.exe" /command:log /path:'.l:file.' /closeonend:0'
endfunction

function! ctrlp#mygit#guiblame()
    let l:file=expand("%:p")
    sil execute ':!cmd.exe /c start "" "C:\Program Files\TortoiseGit\bin\TortoiseGitProc.exe" /command:blame /path:'.l:file.' /closeonend:0'
endfunction

function! ctrlp#mygit#guipull()
    let l:file=expand("%:p")
    sil execute ':!cmd.exe /c start "" "C:\Program Files\TortoiseGit\bin\TortoiseGitProc.exe" /command:sync /path:./ /closeonend:0'
endfunction

function! ctrlp#mygit#vscode()
  let l:file=expand("%:p")
  sil execute ':!cmd.exe /c start "" "C:\Users\lawrencechi\AppData\Local\Programs\Microsoft VS Code\Code.exe" "./"'
endfunction


let g:ctrlp_mygit_cmds=[]
let s:mygit_cmds =[
      \ {'name':'gitpull','cmd':'call ctrlp#mygit#pull()','desc':'git pull'},
      \ {'name':'gitlog','cmd':'call ctrlp#mygit#log()','desc':'git log ./'},
      \ {'name':'gitfilelog','cmd':'call ctrlp#mygit#filelog()','desc':'git file log'},
      \ {'name':'gitblame','cmd':'call ctrlp#mygit#fileblame()','desc':'git blame filename'},
      \ {'name':'gitdiff','cmd':'call ctrlp#mygit#diff()','desc':'git diff filename and file content'},
      \ {'name':'gitguicommit','cmd':'call ctrlp#mygit#guicommit()','desc':'git gui commit'},
      \ {'name':'gitguilog','cmd':'call ctrlp#mygit#guilog()','desc':'git gui log'},
      \ {'name':'gitguifilelog','cmd':'call ctrlp#mygit#guifilelog()','desc':'git gui file log'},
      \ {'name':'gitguiblame','cmd':'call ctrlp#mygit#guiblame()','desc':'git gui file blame'},
      \ {'name':'gitguipull','cmd':'call ctrlp#mygit#guipull()','desc':'git gui pull sync project'},
      \ {'name':'gitvscode','cmd':'call ctrlp#mygit#vscode()','desc':'launch vscode'},
      \ {'name':'gitdesc','cmd':'call ctrlp#mygit#show_commit_detail()','desc':'git show $commit'},
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
	\ 'init': 'ctrlp#mygit#init()',
	\ 'accept': 'ctrlp#mygit#accept',
	\ 'lname': 'my git command',
	\ 'sname': 'mygit',
	\ 'type': 'line',
	\ 'enter': 'ctrlp#mygit#enter()',
	\ 'exit': 'ctrlp#mygit#exit()',
	\ 'opts': 'ctrlp#mygit#opts()',
	\ 'sort': 0,
	\ 'specinput': 0,
	\ })


" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#mygit#init()
  return map(copy(g:ctrlp_mygit_cmds)+s:mygit_cmds,
        \ 'printf("%s\t: %s", v:val.name, v:val.desc)')
endfunction

" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
function! ctrlp#mygit#accept(mode, str)
	" For this example, just exit ctrlp and run help
	call ctrlp#exit()
  let name = split(a:str, "	")[0]
  let cmds = g:ctrlp_mygit_cmds+s:mygit_cmds
  for i in cmds
    if i.name==name
      silent execute ':'.i.cmd
    endif
  endfor
endfunction

" (optional) Do something before enterting ctrlp
function! ctrlp#mygit#enter()
endfunction


" (optional) Do something after exiting ctrlp
function! ctrlp#mygit#exit()
endfunction


" (optional) Set or check for user options specific to this extension
function! ctrlp#mygit#opts()
endfunction


" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

" Allow it to be called later
function! ctrlp#mygit#id()
	return s:id
endfunction

" Key-mapping
nnoremap <silent> <Plug>(ctrlp#mygit#P4ReviewLink) :<C-u>call ctrlp#mygit#P4ReviewLink()<CR>

" Create a command to directly call the new search type
"
" Put this in vimrc or plugin/mygit.vim
" command! CtrlPSample call ctrlp#init(ctrlp#mygit#id())


" vim:nofen:fdl=0:ts=2:sw=2:sts=2
