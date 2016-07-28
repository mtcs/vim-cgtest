if !exists('g:gctest#tests')
	let g:gctest#tests = ["head"]
endif

function! CGTestAll()
	execute "!ctest"
endfunction

function! CGTestRegex(regex)
	execute "!ctest -R " . a:regex
endfunction


function! CGTestInfoRefresh()
	let testlist = system("ctest -N -V")
	let testlines = split(testlist, '\n')
	let grab_envs = 0
	for line in testlines[6:-1]
		let elements = split(line)
		if len(elements) > 0
			if elements[0] == "Test"
				let grab_envs = 0
				let testnum = substitute(elements[1], "[#:]", "", "g")
				let g:gctest#tests[testnum].name = elements[2]
			else
				let testnum = substitute(elements[0], ":", "", "")
				if grab_envs == 0
					if elements[1] == "Test"
						call add(g:gctest#tests, { "cmd" : join(elements[3:-1], " ") } )
						let g:gctest#tests[testnum].env = {}
					elseif elements[1] == "Environment"
						let grab_envs = 1
					endif
				else
					let envval = split(join(elements[1:-1], ' '), "=")
					let g:gctest#tests[testnum]["env"][envval[0]] = envval[1]
				endif
			endif
		endif
	endfor
endfunction

function! CGTestRefresh()
	for test in g:gctest#tests[1:-1]
		if has_key(test, "name")
			echo "Test " . test.name . " - " . test.cmd
			let test.testret = split(system('ctest -V --timeout 20 -R ' . test.name ), "\n")
		endif
	endfor
endfunction

function! CGTestResults()
	if bufexists(bufname('_CGTest_Results_'))
		execute g:cgtest#resultwinnr . "wincmd w"
		setlocal modifiable
		execute "%d"
	else
		silent vsplit _CGTest_Results_
		let g:cgtest#resultwinnr = winnr()
	endif

	setlocal buftype=nofile
	setlocal bufhidden=delete
	setlocal noswapfile
	setlocal nobuflisted
	setlocal nowrap
	setlocal nonumber
	setlocal foldmethod=manual

	call append(0, "------------------- CGTest -------------------" )
	for test in g:gctest#tests[1:-1]
		if has_key(test, "name")
			"echo "\n------------------- " . test.name . " -------------------"
			"echo get(test, "testret", "test not run")
			call append(line('$'), "[ ------------------- " . test.name . " ------------------- ]" )
			let test_text = get(test, "testret", "test not run")
			call append(line('$'), test_text )
			execute line('$') - len(test_text) . "," line('$') . "fold"
		endif
	endfor
	setlocal nomodifiable
	foldclose!
endfunction

function! CGTest()
	call CGTestRefresh()
	call CGTestResults()
endfunction

nnoremap <leader>cgt :call CGTest()<CR>

call CGTestInfoRefresh()

command! CGTest call CGTest()
command! CGTestAll call CGTestAll()
command! CGTestRefresh call CGTestRefresh()
command! CGTestInfoRefresh call CGTestInfoRefresh()
command! CGTestResults call CGTestResults()
command! -nargs=1 CGTestR call CGTestRegex(<f-args>)
command! -nargs=1 CGTestRegex call CGTestRegex(<f-args>)

