function! s:CGTest()
	execute "!ctest"
endfunction

function! s:CGTestRegex(regex)
	execute "!ctest -R " . a:regex
endfunction


