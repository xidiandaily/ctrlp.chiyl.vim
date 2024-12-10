"==============================================================================
" Description: global plugin for lawrencechi
" Author:      lawrencechi <codeforfuture <at> 126.com>
" Last Change: 2022.11.02
" License:     This file is placed in the public domain.
" Version:     1.0.0
"==============================================================================

" To load this extension into ctrlp, add this to your vimrc:
"
"     let g:ctrlp_extensions = ['mycmd']
"
" Where 'mycmd' is the name of the file 'mycmd.vim'
"
" For multiple extensions:
"
"     let g:ctrlp_extensions = [
"         \ 'my_extension',
"         \ 'my_other_extension',
"         \ ]
echom "Loading..."

" Load guard
if ( exists('g:loaded_ctrlp_mycmd') && g:loaded_ctrlp_mycmd )
	\ || v:version < 700 || &cp
	finish
endif
let g:loaded_ctrlp_mycmd = 1

let s:plugin_path=escape(expand('<sfile>:p:h'),'\')

if has('python3')
  execute 'py3file ' . s:plugin_path . '/lgametag2ctrlp.py'
else
  execute 'pyfile ' . s:plugin_path . '/lgametag2ctrlp.py'
endif

function! ctrlp#mycmd#NerdTreeCurFile()
  let filedir=expand("%:p:h")
  let cmd='NERDTree '.filedir
  silent execute ':'.cmd
  silent execute ':set rnu'
endfunction


function! ctrlp#mycmd#SvnBlame()
  if g:iswindows == 0
    let olddir=getcwd()
    let filedir=expand("%:p:h")
    let filename=expand("%:p:t")
    let l:blamefilename="/tmp/".expand("%:p:t").'.blame'
    let l:blamefilename_v="/tmp/".expand("%:p:t").'.blame.v'
    silent execute ':cd '.filedir
    silent execute ':! svn blame -x -b -x --ignore-eol-style '.filename.' > '.l:blamefilename
    silent execute ':! svn blame -x -b -x --ignore-eol-style -v '.filename.' > '.l:blamefilename_v
python <<EOF
import fileinput
import codecs
import shutil
import os
import vim

infile = vim.eval("l:blamefilename")
infile_v = vim.eval("l:blamefilename_v")
infile_tmp=infile+".tmp"

gLine=[]
for line in fileinput.FileInput(infile_v):
    header=line[:43]
    gLine.append(header)

gLine.reverse()
with codecs.open(infile_tmp,"wc","utf-8") as fileObj:
    for line in fileinput.FileInput(infile):
        content=line[18:].decode("cp936")
        header=gLine.pop()
        strNewLine=header+" "+content
        fileObj.write(strNewLine)
    fileObj.close()
os.unlink(infile_v)
shutil.move(infile_tmp,infile)
EOF
    silent execute ':cd '.olddir
    silent execute ':edit '.l:blamefilename
  else
    let l:file=expand("%:p")
python << EOF
import subprocess
import vim
a_filename = "/path:"+vim.eval("l:file")
p = subprocess.Popen(["TortoiseProc.exe","/command:blame",a_filename],shell=False,stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
out,err=p.communicate()
p.stdin.close()
if err:
    print("Falied!",err)
    sys.exit()
EOF
  endif
endfunction

function! ctrlp#mycmd#TabSplit()
    silent execute ':tab split'
endfunction

fu! ctrlp#mycmd#Xml2Header()
  if isdirectory('protocol')
    let cur_pwd=chdir('protocol')
    if filereadable('xml2header.bat') == 1
      silent! execute '!xml2header.bat'
      if filereadable('star_define.h') == 0
        call writefile(['#ifndef _STAR_DEFINE_H_', '#define _STAR_DEFINE_H_', '', '// 用来放协议的包含关系', '#include "protocol/star_macro.h"', '#include "protocol/star_comm.h"', '#include "protocol/star_def.h"', '#include "protocol/star_cs.h"', '#include "protocol/star_ss.h"', '#include "protocol/star_sync.h"', '#include "protocol/star_res.h"', '#include "protocol/keywords.h"', '#endif	// _STAR_DEFINE_H_',],'star_define.h','w')
      endif
      call chdir(cur_pwd)
    endif
  endif
endfu

fu! ctrlp#mycmd#DelProCfiles()
  if isdirectory('protocol')
    let cur_pwd=chdir('protocol')
    if filereadable('cleanxmlheader.bat') == 1
      silent! execute '!cleanxmlheader.bat'
    endif
    call chdir(cur_pwd)
  endif
endfu


fu! ctrlp#mycmd#LGameCtrlPTag()
  let s:custom_tag_list=[]
  if filereadable('./lgamesvrc.tags') == 1
    silent! execute 'python' . (has('python3') ? '3' : '') . ' GenerateTag2CtrlpTag("./lgamesvrc.tags","./lgamesvrc.ctrlptags")'
    call add(s:custom_tag_list,'./lgamesvrc.ctrlptags')
  endif

  if filereadable('./lgamexml.tags') == 1
    silent! execute 'python' . (has('python3') ? '3' : '') . ' GenerateTag2CtrlpTag("./lgamexml.tags","./lgamexml.ctrlptags",[])'
    call add(s:custom_tag_list,'./lgamexml.ctrlptags')
  endif

  if len(s:custom_tag_list)>1
    let g:ctrlp_custom_tag_files=s:custom_tag_list
    echom "set g:ctrlp_custom_tag_files: ". join(s:custom_tag_list)
  else
    echom "not found anny lgame tags file..."
  endif
endfu

fu! ctrlp#mycmd#PGameCtrlPTag()
  let s:custom_tag_list=[]
  if filereadable('./pgamesvrc.tags') == 1
    silent! execute 'python' . (has('python3') ? '3' : '') . ' PGameGenerateTag2CtrlpTag("./pgamesvrc.tags","./pgamesvrc.ctrlptags")'
    "call add(s:custom_tag_list,'./pgamesvrc.ctrlptags')
  endif

  if filereadable('./pgamexml.tags') == 1
    silent! execute 'python' . (has('python3') ? '3' : '') . ' PGameGenerateTag2CtrlpTag("./pgamexml.tags","./pgamexml.ctrlptags")'
    call add(s:custom_tag_list,'./pgamexml.ctrlptags')
  endif

  if filereadable('./pgamelua.tags') == 1
    silent! execute 'python' . (has('python3') ? '3' : '') . ' PGameGenerateTag2CtrlpTag("./pgamelua.tags","./pgamelua.ctrlptags")'
    call add(s:custom_tag_list,'./pgamelua.ctrlptags')
  endif

  if len(s:custom_tag_list)>1
    let g:ctrlp_custom_tag_files=s:custom_tag_list
    echom "set g:ctrlp_custom_tag_files: ". join(s:custom_tag_list)
  else
    echom "not found anny lgame tags file..."
  endif
endfu

fu! ctrlp#mycmd#ChangesForOwner()
  let filename=expand('%:p:t')
  if filename != '.myp4.out.googlechanges'
    echom "current file (".filename. ") is not .myp4.out.googlechanges, exit"
    return
  endif
  let cur_owner=expand('<cword>')
  if type(cur_owner)!=1
    let cur_owner=''
  endif
  let owner_input=input('please input owner name [default:' .cur_owner.']:')
  if len(owner_input)==0
    let owner_input=cur_owner
  endif
  echom "current owner:".owner_input
  let confirm_owenr=input('confirm owner:' .owner_input.'[Yy/Nn]:')
  if confirm_owenr == 'Y' || confirm_owenr=='y'
  else
    return
  endif
  silent execute ':norm ggjma'
  silent execute ':norm Gmb'
  silent execute ":\'a,\'b v/\:\\d\\d\t".owner_input.'\t/del'
endfu

function! ctrlp#mycmd#vscode()
  let l:file=expand("%:p")
  sil execute ':!cmd.exe /c start "" "D:\Users\lawrencechi\AppData\Local\Programs\Microsoft VS Code\Code.exe" "./" '.l:file.''
endfunction


let s:mycmd_cmds =[
      \ {'name':'1.vscode','cmd':'call ctrlp#mycmd#vscode()','desc':'open vscode On Cur folder '},
      \ {'name':'2.cft','cmd':'call ctrlp#mycmd#NerdTreeCurFile()','desc':'open NERDTree On Cur file folder'},
      \ {'name':'3.nt','cmd':'NERDTree','desc':'NERDTree'},
      \ {'name':'4.svnblame','cmd':'call ctrlp#mycmd#SvnBlame()','desc':'svn blame Cur file'},
      \ {'name':'5.xml2head','cmd':'call ctrlp#mycmd#Xml2Header()','desc':'run lgame protocol/xml2header.bat'},
      \ {'name':'6.delprocfile','cmd':'call ctrlp#mycmd#DelProCfiles()','desc':'del protocol c source file(*.pack.c/.h)'},
      \ {'name':'7.ts','cmd':'call ctrlp#mycmd#TabSplit()','desc':'tabsplit opens current buffer in new tab page'},
      \ {'name':'8.ctag2lgame','cmd':'call ctrlp#mycmd#LGameCtrlPTag()','desc':'generate a tag for lgmae'},
      \ {'name':'9.changes5owner','cmd':'call ctrlp#mycmd#ChangesForOwner()','desc':'googlechanges find spectial owner, to google'},
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
	\ 'init': 'ctrlp#mycmd#init()',
	\ 'accept': 'ctrlp#mycmd#accept',
	\ 'lname': 'my command',
	\ 'sname': 'mycmd',
	\ 'type': 'line',
	\ 'enter': 'ctrlp#mycmd#enter()',
	\ 'exit': 'ctrlp#mycmd#exit()',
	\ 'opts': 'ctrlp#mycmd#opts()',
	\ 'sort': 0,
	\ 'specinput': 0,
	\ })


" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#mycmd#init()
  return map(copy(g:ctrlp_mycmd_cmds)+s:mycmd_cmds,
        \ 'printf("%s\t: %s", v:val.name, v:val.desc)')
endfunction

" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
function! ctrlp#mycmd#accept(mode, str)
	" For this example, just exit ctrlp and run help
	call ctrlp#exit()
  let name = split(a:str, "	")[0]
  let cmds = g:ctrlp_mycmd_cmds+s:mycmd_cmds
  for i in cmds
    if i.name==name
      silent execute ':'.i.cmd
    endif
  endfor
endfunction

" (optional) Do something before enterting ctrlp
function! ctrlp#mycmd#enter()
endfunction


" (optional) Do something after exiting ctrlp
function! ctrlp#mycmd#exit()
endfunction


" (optional) Set or check for user options specific to this extension
function! ctrlp#mycmd#opts()
endfunction


" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

" Allow it to be called later
function! ctrlp#mycmd#id()
	return s:id
endfunction


" Create a command to directly call the new search type
"
" Put this in vimrc or plugin/mycmd.vim
" command! CtrlPSample call ctrlp#init(ctrlp#mycmd#id())


" vim:nofen:fdl=0:ts=2:sw=2:sts=2
