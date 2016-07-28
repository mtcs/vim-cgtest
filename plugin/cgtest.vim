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

function! CGTest()
	for test in g:gctest#tests[1:-1]
		echo "Test" . test.name . " - " . test.cmd
		let test.testret = system('ctest -V --timeout 20 -R ' . test.name )
	endfor
endfunction

function! CGTestResults()
	for test in g:gctest#tests[1:-1]
		echo "\n------------------- " . test.name . " -------------------"
		echo get(test, "testret", "test not run")
	endfor
endfunction

nnoremap <leader>cgt :call CGTest()<CR>

call CGTestInfoRefresh()

command! CGTest call CGTest()
command! CGTestAll call CGTestAll()
command! CGTestRegex call CGTestRegex()
command! CGTestRefresh call CGTestRefresh()
command! CGTestResults call CGTestResults()
command! -nargs=1 CGTestR call CGTestRegex(<f-args>)

