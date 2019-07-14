" https://github.com/janko/vim-test#extending

if !exists('g:test#cpp#bazel#file_pattern')
  let g:test#cpp#bazel#file_pattern = '\v(test_\w+|\w+_test)\.(cc|cpp|cxx)$'
endif

function! test#cpp#bazel#test_file(file)
  if fnamemodify(a:file, ':t') =~# g:test#cpp#bazel#file_pattern
    return executable('bazel')
  endif
endfunction

function! test#cpp#bazel#build_position(type, position)
  let filename = @%
  if a:type ==# 'file' || a:type ==# 'nearest'
    " https://docs.bazel.build/versions/master/query-how-to.html#what-is-the-build-label-for-path-to-file-bar-java
    let filelabel = trim(system('bazel query ' . filename . ' 2> /dev/null'))
    let package_label = split(filelabel, ':')[0] . ':*'
    " https://docs.bazel.build/versions/master/query-how-to.html#what-rule-target-s-contain-file-path-to-file-bar-java-as-a-sourc
    let cmd = 'bazel query "attr(srcs, ' . filelabel . ', ' . package_label . ')" 2> /dev/null'
    let output = trim(system(cmd))
    let targets = split(output)
    return targets
  elseif a:type ==# 'suite'
    " https://docs.bazel.build/versions/master/query-how-to.html#what-package-contains-file-path-to-file-bar-java
    let cmd = 'bazel query ' . filename . ' --output=package' . ' 2> /dev/null'
    let output = trim(system(cmd))
    let target = '//' . output  . '/...'
    let targets = [target]
    return targets
  else
    return []
  endif
endfunction

function! test#cpp#bazel#build_args(args)
  let args = ['test']

  if test#base#no_colors()
    args = args + ['--color=no']
  endif

  return args + a:args
endfunction

function! test#cpp#bazel#executable()
  return 'bazel'
endfunction
