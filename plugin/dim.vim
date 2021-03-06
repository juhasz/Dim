if has("autocmd")
  " Drupal php files.
  augroup module
    autocmd BufRead,BufNewFile *.{module,install,test,inc,profile} set filetype=php
    autocmd BufRead,BufNewFile *.{info,make,build} set filetype=dosini
    autocmd FileType php setlocal textwidth=80
    autocmd FileType php setlocal formatoptions=clorq
    autocmd FileType php call DrupalSetTags()
  augroup END
endif

if has("cscope")

  function! DrupalCreateCscope()
    call DrupalSetRootDir()
    cs kill 0
    exec '!find '  . b:DrupalRoot . ' -name \*.php > /tmp/csfiles && cscope -b -i /tmp/csfiles'
    exec '!find '  . b:DrupalRoot . ' -name \*.js >> /tmp/csfiles && cscope -b -i /tmp/csfiles'
    exec '!find '  . b:DrupalRoot . ' -name \*.module >> /tmp/csfiles && cscope -b -i /tmp/csfiles'
    exec '!find '  . b:DrupalRoot . ' -name \*.info >> /tmp/csfiles && cscope -b -i /tmp/csfiles'
    exec '!find '  . b:DrupalRoot . ' -name \*.install >> /tmp/csfiles && cscope -b -i /tmp/csfiles'
    exec '!find '  . b:DrupalRoot . ' -name \*.inc >> /tmp/csfiles && cscope -b -i /tmp/csfiles'
    exec '!find '  . b:DrupalRoot . ' -name \*.test >> /tmp/csfiles && cscope -b -i /tmp/csfiles'
    exec '!find '  . b:DrupalRoot . ' -name \*.profile >> /tmp/csfiles && cscope -b -i /tmp/csfiles'
    exec '!find '  . b:DrupalRoot . ' -name \*.make >> /tmp/csfiles && cscope -b -i /tmp/csfiles'
    cs add .
    !rm -f /tmp/csfiles
  endfunction
  command! DrupalCreateCscope call DrupalCreateCscope()
endif

" functions
function! DrupalSetRootDir(...)
  if exists('a:1')
    let b:DrupalRoot = a:1
    return 0
  endif
  " get the file directory
  let l:dir = expand('%:p:h')
  " search for a Drupal root in the parent directories
  while 1

    if file_readable(l:dir . '/index.php') && (file_readable(l:dir . '/core/includes/bootstrap.inc') || file_readable(l:dir . '/includes/bootstrap.inc'))
      break
    endif

    let l:pathList = split(l:dir, '/')
    let l:dir = ''
    unlet l:pathList[-1]

    " if no more parent directories, set the default Drupal directory
    if len(l:pathList) > 0
      for l:d in l:pathList
        let l:dir .= '/' . l:d
      endfor
    else
      if exists('g:DrupalDefaultRoot')
        let l:dir = g:DrupalDefaultRoot
      else
        let l:dir = getcwd()
      endif
      break
    endif

  endwhile

  let b:DrupalRoot = l:dir
endfunction

function! DrupalCdDrupalRoot(...)
  call DrupalSetRootDir()
  if exists('a:1')
    let l:context = a:1
  else
    let l:context = 'g'
  endif

  if l:context == 'g'
    let l:command = 'cd'
  elseif l:context == 'l'
    let l:command = 'lcd'
  endif

  exec l:command . ' ' . b:DrupalRoot
  pwd
endfunction

function! DrupalSetTags()
  call DrupalSetRootDir()
  let l:tags = b:DrupalRoot . '/tags'
  if file_readable(l:tags)
    exec 'setlocal tags+=' . l:tags
  else
    echomsg 'tags file is not exists, run DrupalCreateTags command to create it!'
  endif
endfunction

function! DrupalCreateTags()
  call DrupalSetRootDir()
  exec '!cd ' . b:DrupalRoot . '; ctags'
  echomsg 'tags file for Drupal project created.'
  call DrupalSetTags()
endfunction

" commands
command! -nargs=* DrupalSetRootDir call DrupalSetRootDir(<f-args>)
command! Dcd call DrupalCdDrupalRoot()
command! Dlcd call DrupalCdDrupalRoot('l')
command! DrupalSetTags call DrupalSetTags()
command! DrupalCreateTags call DrupalCreateTags()
