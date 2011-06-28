" functions
function! DrupalFuncSearch(func)
  let l:func = a:func

  " remove quote paris from function name
  let l:pairs = ['"', "'", '/']
  if l:func[0] == l:func[len(l:func) - 1] && index(l:pairs, l:func[0]) >= 0
    let l:func = l:func[1:-2]
  endif

  " set the beginning of function name, to work with or without beginning '^'
  if l:func[0] == '^'
    let l:expBeg = ' '
    let l:func = l:func[1:-1]
  else
    let l:expBeg = '[^(]*'
  endif

  " set the end of function name, to work with or without trailing '$'
  if l:func[len(l:func) - 1] == '$'
    let l:expEnd = ''
    let l:func = l:func[0:-2]
  else
    let l:expEnd = '[^(]*'
  endif

  " RegularExpression for search
  let l:regExp = '^function' . l:expBeg . l:func . l:expEnd . '('
  exec 'silent grep! -R "' . l:regExp . '" ' . b:DrupalRoot
endfunction

function! DrupalSetRootDir(...)
  if exists('a:1')
    let b:DrupalRoot = a:1
    return 0
  endif
  " get the working directory
  let l:dir = getcwd()
  " search for a Drupal root in the parent directories
  while !file_readable(l:dir . '/includes/bootstrap.inc')
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

" commands
command! -nargs=1 DrupalFuncSearch call DrupalFuncSearch(<f-args>)
command! -nargs=* DrupalSetRootDir call DrupalSetRootDir(<f-args>)
