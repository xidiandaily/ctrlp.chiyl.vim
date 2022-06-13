" Load guard
if ( exists('g:loaded_ctrlp_mybase') && g:loaded_ctrlp_mybase)
	\ || v:version < 700 || &cp
	finish
endif
let g:loaded_ctrlp_mybase = 1

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

" vim:nofen:fdl=0:ts=2:sw=2:sts=2
