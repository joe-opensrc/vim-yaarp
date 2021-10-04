" vim-yaarp -- Yet Another Ascii Related Plugin
" Maintainer:   Joe OpenSrc
" Version:      0.1
" GetLatestVimScripts: 4359 1 :AutoInstall: yaarp.vim

if exists("g:loaded_yaarp") || v:version < 801 || &cp
  finish
endif
let g:loaded_yaarp = 0.1

let g:yaarp_enabled = 0
let s:yaarp_save_statusline = &statusline

" TODO: save current
set virtualedit=all

fun! YaarpIsEnabled()
  return g:yaarp_enabled
endfunction

fun! s:toggle(v)
  
  if a:v
    return 0 " falsy
  else
    return 1 " truthy
  endif 
  
endfunction

fun! YaarpToggle() 

  " toggle current setting
  let g:yaarp_enabled = s:toggle( g:yaarp_enabled )
  call YaarpSetStatusline()

endfunction

fun! YaarpSetStatusline()

  " if plugin is enabled
  if g:yaarp_enabled == 1
   
    " save current statusline
    " set some reasonable colors 
    " TODO: learn how to save & restore hi 
    hi StatusLine term=bold,reverse ctermfg=32 ctermbg=0 guifg=#277BD3 guibg=#BFD7DB

    " always start with:
    set statusline=[YAARP\:

    if s:erase_mode == 1
      set statusline+=\ Erase
    endif                  

    " potentially other stuff
    let l:r = getpos('.')[1]
    let l:c = virtcol('.')

    set statusline+=%{YaarpGetCursorPos()}
    set statusline+=]

  else
    let &statusline = s:yaarp_save_statusline
  endif

  echo s:yaarp_save_statusline

endfunction

fun! YaarpGetCursorPos()
  return '[' . getpos('.')[1] . ',' . virtcol('.') . ']'
endfunction


let s:the_glyph   = '*'
let s:erase_char  = ' '
let s:erase_mode  = 0
let s:force_char  = 0
let s:force_menu  = 0
let s:force_guess = 0
let s:yaarp_status = "YAARP"

let g:yaarp_ts = 'ascii' 

let s:chooser          = {}
let s:chooser.ts       = {}
let s:chooser.ts.box   = {}
let s:chooser.ts.ascii = {}

let s:chooser.ts['ascii'].e  = ' ' 
let s:chooser.ts['ascii'].h  = '-' 
let s:chooser.ts['ascii'].v  = '|'
let s:chooser.ts['ascii'].dr = '/' 
let s:chooser.ts['ascii'].dl = '\' 
let s:chooser.ts['ascii'].i  = '+'
let s:chooser.ts['ascii'].x  = 'x'
let s:chooser.ts['ascii'].tl = '+' " '┌'
let s:chooser.ts['ascii'].tr = '+' " '┐'
let s:chooser.ts['ascii'].bl = '+' " '└'
let s:chooser.ts['ascii'].br = '+' " '┘'

fun! YaarpJumpCursor(...)

  let l:r = get( a:, 1,  0  )
  let l:c = get( a:, 2,  0  )

  exe 'norm! ' . l:r . 'G' . l:c . '|'

endfunction

fun! YaarpJumpCursorRel(...)

  let l:lo = get( a:, 1,  0  )
  let l:co = get( a:, 2,  0  )

  let l:dir = ''

  if l:lo != 0
    if l:lo > 0

      if( getpos('.')[1] + l:lo ) > line('$')
        call append( line('$'), repeat( l:lo, '' ) ) 
      endif

      let l:dir = l:lo . 'j'

    else

      if (getpos('.')[1] + l:lo ) < 1 
        call append( 0, repeat( l:lo, '' ) ) 
      endif

      let l:dir = abs(l:lo) . 'k'

    endif


    echo l:dir
    exe 'norm! ' . l:dir
  endif

  if l:co != 0 
    if l:co > 0 

     let l:dir = l:co . 'l'
    else
      let l:dir = abs(l:co) . 'h'
    endif

    exe 'norm! ' . l:dir
  endif

endfunction

fun! YaarpHandleMove(...) range abort

  let l:lo = get( a:, 1,  0  )
  let l:co = get( a:, 2,  0  )
  
  let l:dir = [l:lo, l:co]

  let l:c = YaarpGetChar()

  if l:dir == [0,-1] || l:dir == [0,1] " horiz w/intersection

    if l:c == YaarpChooseGlyph('i')

      call YaarpPutChar(YaarpChooseGlyph('h'))

    elseif l:c == YaarpChooseGlyph('v') || ( YaarpGetChar(-1,0) == YaarpChooseGlyph('v') || YaarpGetChar(1,0) == YaarpChooseGlyph('v') ) 

      call YaarpPutChar(YaarpChooseGlyph('i'))

    elseif l:c != YaarpChooseGlyph('i') 

      call YaarpPutChar(YaarpChooseGlyph('h'))

    endif
  
    call YaarpJumpCursorRel(l:lo, l:co)

  endif

  if l:dir == [-1,0] || l:dir == [1,0] " vertical

    if l:c == YaarpChooseGlyph('i')

      call YaarpPutChar(YaarpChooseGlyph('v'))

    elseif l:c == YaarpChooseGlyph('h') || ( YaarpGetChar(0,-1) == YaarpChooseGlyph('h') || YaarpGetChar(0,1) == YaarpChooseGlyph('h') )
      call YaarpPutChar(YaarpChooseGlyph('i'))
    else
      call YaarpPutChar( YaarpChooseGlyph('v') )
    endif

    call YaarpJumpCursorRel(l:lo, l:co)

  endif


  if l:dir == [-1,-1] || l:dir == [1,1]  "dl 
    
    if l:c == YaarpChooseGlyph('x')
      call YaarpPutChar(YaarpChooseGlyph('dl'))
      call YaarpJumpCursorRel(l:lo, l:co )
      return 0
    endif

    if l:c == YaarpChooseGlyph('dr')  || YaarpGetChar(1,-1) == YaarpChooseGlyph('dr') || YaarpGetChar(-1,1) == YaarpChooseGlyph('dr') 
      call YaarpPutChar(YaarpChooseGlyph('x'))
      call YaarpJumpCursorRel(l:lo,  l:co )
      " call YaarpPutChar(YaarpChooseGlyph('dl'))
    else
      call YaarpPutChar(YaarpChooseGlyph('dl'))
      call YaarpJumpCursorRel(l:lo, l:co )
    endif
     
  return 0
  endif


  if l:dir == [-1,1] || l:dir == [1,-1]  "dr 

    if l:c == YaarpChooseGlyph('x')
      call YaarpPutChar(YaarpChooseGlyph('dr') )
      call YaarpJumpCursorRel( l:lo, l:co)
      return 0
    endif
    
    if l:c == YaarpChooseGlyph('dl') || YaarpGetChar(1,1) == YaarpChooseGlyph('dl') || YaarpGetChar(-1,-1) == YaarpChooseGlyph('dl')
      call YaarpPutChar(YaarpChooseGlyph('x'))
      call YaarpJumpCursorRel( l:lo,  l:co )
      " call YaarpPutChar(YaarpChooseGlyph('dr'))
    else
      call YaarpPutChar(YaarpChooseGlyph('dr'))
      call YaarpJumpCursorRel( l:lo,  l:co )
    endif
     
  return 0
  endif



endfunction

fun! YaarpRect() range abort

  " rectangle row/column start/end
  let l:rrs   = line("'<")
  let l:rcs   = virtcol("'<")

  let l:rre   = line("'>")
  let l:rce   = virtcol("'>")

  if [l:rrs,l:rcs,l:rre,l:rce] == [0,0,0,0]
    return 0 
  endif

  let l:rrt = 0
  let l:rct = 0

  if l:rrs > l:rre 
    let l:rrt = l:rre
    let l:rre = l:rrs
    let l:rrs = l:rrt
  endif

  if l:rcs > l:rce 
    let l:rct = l:rce
    let l:rce = l:rcs
    let l:rcs = l:rct
  endif
  
  let l:coloff = l:rce - l:rcs
  let l:rowoff = l:rre - l:rrs

  echo "RectBounds: " . string([l:rrs,l:rcs,l:rre,l:rce]) . ", curr: " . string( getpos('.')[1:2] ) . ", rowoff: " . l:rowoff . ",coloff: " . l:coloff

  for l:c in [ l:rcs, l:rce ]
    
    for l:y in range( l:rrs + 1, l:rre - 1 )

      echo l:c . "," . l:y
      call YaarpJumpCursor( l:y, l:c )
      call YaarpPutChar( YaarpChooseGlyph('v') )

    endfor

  endfor


  for l:r in [ l:rrs, l:rre ]

    for l:x in range( l:rcs + 1, l:rce - 1 ) 
      
      call YaarpJumpCursor(l:r, l:x ) 
      call YaarpPutChar( YaarpChooseGlyph('h') )

    endfor


  endfor


  call YaarpJumpCursor(l:rrs,l:rcs) 
  call YaarpPutChar( YaarpChooseGlyph('tl') ) ", 0, len( YaarpChooseGlyph('tr') ) ) 

  call YaarpJumpCursor(l:rrs,l:rce)
  call YaarpPutChar( YaarpChooseGlyph('tr') ) ", 0, len( YaarpChooseGlyph('tl') ) ) 
  
  call YaarpJumpCursor(l:rre,l:rcs) 
  call YaarpPutChar( YaarpChooseGlyph('bl') ) ", 0, len( YaarpChooseGlyph('bl') ) ) 

  call YaarpJumpCursor(l:rre,l:rce) 
  call YaarpPutChar( YaarpChooseGlyph('br') ) ", 0, len( YaarpChooseGlyph('br') ) ) 

endfunction

fun! YaarpHandleKeyPress(k) range abort

  if g:yaarp_enabled == 1

    let l:c = YaarpGetChar()

    if a:k == 'D'
      let s:erase_mode = s:toggle( s:erase_mode ) 
    endif

    " TODO: range replace non-space with space; think visual mode 
    if a:k == 'x'
      exe 'sil! norm! r' . s:erase_char 
    endif

    if a:k == 'M'

      call YaarpRect()   

    endif


    if a:k == 'H'      

      call YaarpHandleMove(0,-1)

    elseif a:k == 'L'

      call YaarpHandleMove(0,1)

    elseif a:k == 'J'

      call YaarpHandleMove(1,0)

    elseif a:k == 'K'

      call YaarpHandleMove(-1,0)

    elseif a:k == 'Y'

      call YaarpHandleMove(-1,-1)

    elseif a:k == 'U'

      call YaarpHandleMove(-1,1)

    elseif a:k == 'B'

      call YaarpHandleMove(1,-1)

    elseif a:k == 'N'

      call YaarpHandleMove(1,1)

    endif

  endif

  " do that
  call YaarpSetStatusline()
  

endfunction

fun! YaarpGetChar(...)

  let l:lo = get( a:, 1, 0 )
  let l:co = get( a:, 2, 0 )

  let l:peek_line = getpos('.')[1] + l:lo 
  let l:peek_col  = virtcol('.')   + l:co - 1 

  let l:ret = matchstr( getline( l:peek_line ), '.', l:peek_col )
  " call setline(2, '"' . l:ret .'"' )
  return l:ret

endfunction

fun! YaarpChooseGlyph(...)

  let l:t  = get( a:, 1, 'e' )
  let l:ts = get( a:, 2, g:yaarp_ts )
  
  if has_key( s:chooser.ts, l:ts ) && has_key( s:chooser.ts[l:ts], l:t )
    return s:chooser.ts[l:ts][l:t] 
  else 
    return 0
  endif

endfunction

fun! YaarpPutChar(...)

  let l:c  = get( a:, 1, '@' )
  let l:lo = get( a:, 2,  0  )
  let l:co = get( a:, 3,  0  )
  let l:jump_back = get( a:, 4, 0 ) " jump back to orig pos; default false 

  if s:erase_mode == 1
    let l:c = s:erase_char
  endif
  
  let l:save_pos = YaarpJumpCursorRel( l:lo,  l:co )
  exe 'silent! norm r' . l:c

  if l:jump_back != 0
    call cursor( l:save_pos )
  endif

endfunction
    
let s:save_cpo = &cpo
set cpo&vim

nnoremap <C-F> :call YaarpToggle()<CR>
inoremap <C-F> <C-R>=YaarpToggle()<CR>

nnoremap D :silent! call YaarpHandleKeyPress('D')<CR>
noremap x :silent! call YaarpHandleKeyPress('x')<CR>

nnoremap  M <C-V>
vnoremap  M :call YaarpRect()<CR> 

nnoremap H :silent! call YaarpHandleKeyPress('H')<CR>
nnoremap L :silent! call YaarpHandleKeyPress('L')<CR>
nnoremap J :silent! call YaarpHandleKeyPress('J')<CR>
nnoremap K :silent! call YaarpHandleKeyPress('K')<CR>

nnoremap Y :silent! call YaarpHandleKeyPress('Y')<CR>
nnoremap U :silent! call YaarpHandleKeyPress('U')<CR>
nnoremap B :silent! call YaarpHandleKeyPress('B')<CR>
nnoremap N :silent! call YaarpHandleKeyPress('N')<CR>

let &cpo = s:save_cpo
