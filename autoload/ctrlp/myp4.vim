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
let s:plugin_path=escape(expand("<sfile>:p:h"),'\')

if has('python3')
  execute 'py3file ' . s:plugin_path . '/p4change2singleline.py'
else
  execute 'pyfile ' . s:plugin_path . '/p4change2singleline.py'
endif

function! ctrlp#myp4#P4Edit()
    let l:file=expand("%:p")
    silent execute ':!p4 edit '.l:file
endfunction

function! ctrlp#myp4#P4Revert()
    let l:file=expand("%:p")
    silent execute ':!p4 revert '.l:file
    call ctrlp#myp4#P4Opened()
endfunction

function! ctrlp#myp4#P4RevertAll()
    silent execute ':!p4 revert ...'
    call ctrlp#myp4#P4Opened()
endfunction

function! ctrlp#myp4#P4Opened()
    let s:out='.myp4.out.opened'
    execute ':!p4  -Ztag -F "action:\%action\%,	type:\%type\%,	localfile: \%clientFile\% ,\#\%rev\%,	change:\%change\%" opened | sed "s/\/\/.*_proj\///" >'.s:out
    call ctrlp#mybase#ctrlp_open_new_win(s:out,0)
endfunction

function! ctrlp#myp4#P4Annotate()
    let l:file=expand("%:p")
    let s:out='.myp4.out.annotate'
    execute ':!p4 annotate -dw -c -u '.l:file.' >'.s:out
    call ctrlp#mybase#ctrlp_open_new_win(s:out,0)
endfunction

function! ctrlp#myp4#P4AnnotateA()
    let l:file=expand("%:p")
    let s:out='.myp4.out.annotate'
    let s:show_full_annotate=input('show full annotate file ?(Yy/Nn)(Default:N):')
    if s:show_full_annotate == 'Y' || s:show_full_annotate == 'y'
      execute ':!p4 annotate -dw -c -u -a '.l:file.' >'.s:out
    else
      let s:rev=ctrlp#mybase#strlp_link_to_changenum(input('please input rev num[default:1000]:'))
      if str2nr(s:rev,10) == 0
        let s:rev=1000
      endif
      execute ':!p4 annotate -c -u '.l:file.'\#'.s:rev.' >'.s:out
    endif
    call ctrlp#mybase#ctrlp_open_new_win(s:out,0)
endfunction

function! ctrlp#myp4#P4Diff()
    let l:file=expand("%:p")
    let s:use_beyon_compare=input('show diff with BeyondCompare(Yy/Nn)(Default:N):')
    if s:use_beyon_compare == 'Y' || s:use_beyon_compare == 'y'
      silent execute ':!p4 set P4DIFF="C:\Program Files\Beyond Compare 4\BCompare.exe" && p4 diff '.l:file
    else
      let s:out='.myp4.out.diff'
      silent execute ':!p4 set P4DIFF="" && p4 diff '.l:file.' > '.s:out
      call ctrlp#mybase#ctrlp_open_new_win(s:out,0)
    endif
endfunction

function! ctrlp#myp4#P4Describe()
    let l:file=expand("%:p")
    let s:wordUnderCursor = str2nr(expand("<cword>"),10)
    if s:wordUnderCursor > 0
      let s:changenum=ctrlp#mybase#strlp_link_to_changenum(input('please input change num[default:'.s:wordUnderCursor.']:'))
      if str2nr(s:changenum,10) == 0
        let s:changenum=s:wordUnderCursor
      endif
    else
      let s:changenum=ctrlp#mybase#strlp_link_to_changenum(input('please input change num[default:new]:'))
    endif

    let s:out='.myp4.out.describe'
    if s:changenum == 0
      execute ':!p4 change -o >'.s:out
    else
      let s:showdiff=input('show diff(Yy/Nn)(Default:N):')
      if s:showdiff == 'Y' || s:showdiff =='y'
        let s:contextlen=input('show diff context length(default:1):')
        if str2nr(s:contextlen,10) == 0
          let s:contextlen=1
        else
          let s:contextlen=s:contextlen
        endif
        execute ':!p4 describe -Sa -du'.s:contextlen.' -dl -db '.s:changenum.' >'.s:out
        execute ':!echo /* vim: set filetype=diff : */ >>'.s:out
      else
        execute ':!p4 describe -s -Sa '.s:changenum.' >'.s:out
      endif
    endif
    call ctrlp#mybase#ctrlp_open_new_win(s:out,0)
endfunction


function! ctrlp#myp4#P4Sync()
    let s:out='.myp4.out.sync'
    execute ':!p4 sync --parallel=0 | tee '.s:out
    call ctrlp#mybase#ctrlp_open_new_win(s:out,0)
endfunction

function! ctrlp#myp4#P4Filelog()
    let l:file=expand("%:p")
    let s:out='.myp4.out.filelog'
    execute ':!p4 filelog -i -l '.l:file.' > '.s:out
    call ctrlp#mybase#ctrlp_open_new_win(s:out,0)
endfunction

function! ctrlp#myp4#P4Unshelve()
    let changenum=ctrlp#mybase#strlp_link_to_changenum(input('please input changenum(link):'))
    if changenum > 0
      let s:out='.myp4.out.open'
      execute ':!p4 unshelve -s '.changenum
      call ctrlp#myp4#P4Opened()
    endif
endfunction

function! ctrlp#myp4#P4Changes()
    let daycnt=ctrlp#mybase#strlp_link_to_changenum(input('How many days to display(default:1,today):'))
    if daycnt ==0
      let daycnt=1
    endif
    let mytime=localtime()-(daycnt-1)*86400
    let s:out='.myp4.out.changes'
    execute ':!p4 changes -s submitted -t -l ...'.strftime("@%Y/%m/%d,@now",mytime).' >'.s:out
    call ctrlp#mybase#ctrlp_open_new_win(s:out,0)

    let s:out='.myp4.out.googlechanges'
    execute 'python' . (has('python3') ? '3' : '') . ' P4Changes2GoogleDoc()'
    call ctrlp#mybase#ctrlp_open_new_win(s:out,0)
endfunction

function! ctrlp#myp4#P4ReviewLink()
    let s:wordUnderCursor = str2nr(expand("<cword>"),10)
    if s:wordUnderCursor > 0
      let s:changenum=ctrlp#mybase#strlp_link_to_changenum(input('please input change num[default: https://cr.lgame.qq.com/changes/'.s:wordUnderCursor.']:'))
      if str2nr(s:changenum,10) == 0
        let s:changenum=s:wordUnderCursor
      endif
    else
      let s:changenum=ctrlp#mybase#strlp_link_to_changenum(input('please input change num: https://cr.lgame.qq.com/changes/'))
    endif

    if s:changenum != 0
      call openbrowser#open('https://cr.lgame.qq.com/changes/'.s:changenum)
      "silent ':OpenBrowser https://cr.lgame.qq.com/changes/'.s:changenum
    endif
  endfunction

let g:ctrlp_myp4_cmds=[]
let s:myp4_cmds =[
      \ {'name':'p4edit','cmd':'call ctrlp#myp4#P4Edit()','desc':'p4 edit'},
      \ {'name':'p4revertall','cmd':'call ctrlp#myp4#P4RevertAll()','desc':'p4 revert all'},
      \ {'name':'p4revert','cmd':'call ctrlp#myp4#P4Revert()','desc':'p4 revert'},
      \ {'name':'p4diff','cmd':'call ctrlp#myp4#P4Diff()','desc':'p4 diff, compares files in your workspace to revisions in the depot'},
      \ {'name':'p4opened','cmd':'call ctrlp#myp4#P4Opened()','desc':'p4 opened '},
      \ {'name':'p4annotate','cmd':'call ctrlp#myp4#P4Annotate()','desc':'p4 annotate -u -c '},
      \ {'name':'p4describe','cmd':'call ctrlp#myp4#P4Describe()','desc':'p4 change -o'},
      \ {'name':'p4sync','cmd':'call ctrlp#myp4#P4Sync()','desc':'p4 sync --parallel=0'},
      \ {'name':'p4filelog','cmd':'call ctrlp#myp4#P4Filelog()','desc':'p4 filelog '},
      \ {'name':'p4unshelve','cmd':'call ctrlp#myp4#P4Unshelve()','desc':'p4 review,unshelve'},
      \ {'name':'p4changes','cmd':'call ctrlp#myp4#P4Changes()','desc':'p4 changes,show history of submitted'},
      \ {'name':'p4reviewlink','cmd':'call ctrlp#myp4#P4ReviewLink()','desc':'openbrowser with review link'},
      \ {'name':'p4annotate-a','cmd':'call ctrlp#myp4#P4AnnotateA()','desc':'p4 annotate -a'},
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

" Key-mapping
nnoremap <silent> <Plug>(ctrlp#myp4#P4ReviewLink) :<C-u>call ctrlp#myp4#P4ReviewLink()<CR>

" Create a command to directly call the new search type
"
" Put this in vimrc or plugin/myp4.vim
" command! CtrlPSample call ctrlp#init(ctrlp#myp4#id())


" vim:nofen:fdl=0:ts=2:sw=2:sts=2
