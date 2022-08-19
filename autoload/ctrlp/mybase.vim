"" Load guard
"if ( exists('g:loaded_ctrlp_mybase') && g:loaded_ctrlp_mybase)
"	\ || v:version < 700 || &cp
"	finish
"endif
"let g:loaded_ctrlp_mybase = 1

function! ctrlp#mybase#ctrlp_open_new_win(fileout,is_writefile)
    if bufexists(a:fileout)
      if len(win_findbuf(bufnr(a:fileout)))==0
        silent execute ':25sv +1 '.a:fileout
      else
        if a:is_writefile
          silent execute ":!touch ".a:fileout
        endif
      endif
    else
      silent execute ':25sv +1 '.a:fileout
    endif
endfunction

function! ctrlp#mybase#strlp_link_to_changenum(link)
  let s:output={'changenum':0}
py3 << EOF
import re
import vim

link=vim.eval('a:link')
output=vim.bindeval('s:output')
result=re.search('(\d+)',link)
if result:
  output['changenum']=int(result.group(1))
EOF
  return str2nr(s:output['changenum'],10)
endfunction

"系统自带的分割函数貌似有问题，对于
"这个字符串无法正常解析
"自己写一个来替换掉
function! ctrlp#mybase#mysplit(line,seq)
  let start=0
  let mylist=[]
  let tmp=''
  let idx=0
  while idx < len(a:line)
    if a:line[idx:idx] == a:seq
      call add(mylist,tmp)
      let tmp=''
    else
      let tmp=tmp.a:line[idx:idx]
    endif
    let idx=idx+1
  endwhile

  if len(tmp) >0
    call add(mylist,tmp)
  endif
  return mylist
endfunction

" vim:nofen:fdl=0:ts=2:sw=2:sts=2
