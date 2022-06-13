" " Load guard
" if ( exists('g:loaded_ctrlp_mylgameowner') && g:loaded_ctrlp_mylowner)
" 	\ || v:version < 700 || &cp
" 	finish
" endif
" let g:loaded_ctrlp_mylowner = 1

let s:fileobjlist=[]
let s:moduleobjlist=[]

"系统自带的分割函数貌似有问题，对于
"这个字符串无法正常解析
"自己写一个来替换掉
function! s:mysplit(line,seq)
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

function! ctrlp#mylowner#lgameownersimplefiles()
  let s:simplefilelist=[]
  for fileobj in s:fileobjlist
    call add(s:simplefilelist,substitute(fileobj['fullname'],"|.*","","g"))
  endfor
  return s:simplefilelist
endfunction


function! ctrlp#mylowner#userlists()
  let memberlist=[]
  for moduleobj in s:moduleobjlist
    for member in moduleobj['members']
      if match(memberlist,member) == -1
        call add(memberlist,member)
      endif
    endfor
  endfor
  return memberlist
endfunction

function! ctrlp#mylowner#namelists()
  let namelists=[]
  for moduleobj in s:moduleobjlist
    call add(namelists,moduleobj['description-en-us'])
  endfor
  return namelists
endfunction

function! ctrlp#mylowner#getmodule_en_us_by_file(filename)
  for fileobj in s:fileobjlist
    if stridx(fileobj['fullname'],a:filename) !=-1
      return fileobj['description-en-us']
    endif
  endfor
  return ''
endfunction

function! ctrlp#mylowner#getmodule_en_us_by_member(member)
  let module_en_us=[]
  for moduleobj in s:moduleobjlist
    "if stridx(moduleobj['owners'],a:member) != -1
    if moduleobj['members'][0]==a:member
      call add(module_en_us,moduleobj['description-en-us'])
    endif
  endfor
  return module_en_us
endfunction

function! ctrlp#mylowner#lgameowner_get_module(module_en_us,isshowlist)
  let outputlist=[]

  call add(outputlist,"============Module Info:BEGIN==========")
  for moduleobj in s:moduleobjlist
    if moduleobj['description-en-us'] == a:module_en_us
      call add(outputlist,"description-en-us".moduleobj['description-en-us'])
      call add(outputlist,"description-zh-cn:".moduleobj['description-zh-cn'])
      call add(outputlist,"docs             :".moduleobj['docs'])
      call add(outputlist,"owners           :".moduleobj['owners'])
      call add(outputlist,"reviewers        :".moduleobj['reviewers'])
      call add(outputlist,"team             :".moduleobj['team'])
      break
    endif
  endfor
  call add(outputlist,"============Module Info:END==========")

  if a:isshowlist >0
    call add(outputlist,"")
    call add(outputlist,"")
    call add(outputlist,"==========Module File List:BEGIN==========")
    for fileobj in s:fileobjlist
      if fileobj['description-en-us'] == a:module_en_us
        call add(outputlist,fileobj['fullname'])
      endif
    endfor
    call add(outputlist,"==========Module File List:END==========")
  endif
  return outputlist
endfunction

function! s:lgameownerinit()
  let s:filelist=readfile("D:\\GitBase\\myLGameTools\\lgame_owner\\lgameowner_file_list.txt")
  let s:modulelist=readfile("D:\\GitBase\\myLGameTools\\lgame_owner\\lgameowner_module_list.txt")

  for line in s:filelist
    let tmp=split(line,'|')
    if len(tmp) != 3
      let tmp=s:mysplit(line,'|')
    endif
    if len(tmp) != 3
      silent execute ":echo 'file'"
      silent execute ":echo line"
    else
      let fileobj={
            \ "description-en-us":tmp[1],
            \ "description-zh-cn":tmp[2],
            \ "fullname":tmp[0]}
      call add(s:fileobjlist,fileobj)
    endif
  endfor

  for line in s:modulelist
    let tmp=split(line,'|')
    if len(tmp) != 7
      let tmp=s:mysplit(line,'|')
    endif
    if len(tmp) != 7
      silent execute ":echo 'module'"
      silent execute ":echo line"
    else
      let moduleobj={
            \ "description-en-us": tmp[0],
            \ "description-zh-cn": tmp[1],
            \ "docs":              tmp[2],
            \ "owners":            tmp[4],
            \ "members":           split(tmp[4],','),
            \ "reviewers":         tmp[5],
            \ "team":              tmp[6]}
      call add(s:moduleobjlist,moduleobj)
    endif
  endfor

  silent execute ":echo len(s:fileobjlist)"
  silent execute ":echo len(s:moduleobjlist)"
endfunction

"先加载数据
call s:lgameownerinit()

" Create a command to directly call the new search type
"
" vim:fen:fdm=marker:fmr={{{,}}}:fdl=0:fdc=1:ts=2:sw=2:sts=2
