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

fu! ctrlp#mybase#debug_print_dict(mydict)
  if type(a:mydict) != type({})
    echomsg "filetype is not dict,current type:".type(a:mydict)
    return
  endif

  for [key,value] in items(a:mydict)
    echomsg "{ ".key.":".value
  endfor
endfu

fu! s:align_comment(line,maxlen)
  let line=a:line
  while len(line) < a:maxlen
    let line=line.' '
  endwhile
  return line.':'
endfu

"自动生成函数注释
fu! ctrlp#mybase#add_function_comment_by_tag()
  let function_name=expand("<cword>")
  let filename=fnamemodify(expand('%'),":p:.")
  let ft=&ft
  if ft!='c' && ft !='cpp'
      echom 'not support ft:'.ft
      return
  endif

  echomsg 'function_name:'. function_name . " filename:". filename . " ft:".ft
  let mymatch=taglist(function_name)
  for mt in mymatch
    "echomsg 'filename:'. fnamemodify(mt['filename'],":p:.")
    if fnamemodify(mt['filename'],":p:.") != filename
      continue
    endif
    if ft=='c' || ft=='cpp'
      "found function name
      "call ctrlp#mybase#debug_print_dict(mt)
      let parameters=split(mt['signature'][1:len(mt['signature'])-2],',')
      let tmp_params=[]
      for param in parameters
        call add(tmp_params,'** @params '.split(param)[-1])
      endfor

      let maxlen=8
      for param in tmp_params
        if len(param) > maxlen
          let maxlen=len(param)
        endif
      endfor

      let comment_lines=['/******************************************************************************']
      call add(comment_lines,s:align_comment("** @desc",maxlen))
      call add(comment_lines,s:align_comment("**",maxlen))
      for param in tmp_params
        call add(comment_lines,s:align_comment(param,maxlen))
      endfor
      call add(comment_lines,s:align_comment("** @return",maxlen))
      call add(comment_lines,s:align_comment("**",maxlen))
      call add(comment_lines,"******************************************************************************/")
      call append(line(".")-1,comment_lines)
      return
    endif
  endfor
  echom 'not found function name'
endfu

"删除文件
fu! ctrlp#mybase#delete_file_if_exist(filename)
  if filereadable(a:filename)
    call delete(a:filename)
    echomsg "delte file:".a:filename
  endif
endfu

"对于 myp4.out.googlechanges 右键直接打开 Describe
fu! ctrlp#mybase#open_p4_describe_from_googlechanges()
  let s:myline=ctrlp#mybase#mysplit(getline(line(".")),'	')
  if len(s:myline) > 1
    let num=str2nr(s:myline[0],10)
    if num == 0
      echomsg "get line change num failed!"
      return
    endif

    let s:out='.myp4.out.describe'
    sil execute ':!p4 describe -Sa -du10 -dl -db '.num.' >'.s:out
    sil execute ':!echo /* vim: set filetype=diff : */ >>'.s:out
    call ctrlp#mybase#ctrlp_open_new_win(s:out,0)
  endif
endfu

" vim:nofen:fdl=0:ts=2:sw=2:sts=2
