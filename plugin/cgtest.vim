if !exists('g:cgtest#tests')
	let g:cgtest#tests = ["head"]
	let g:cgtest#testnum = {}
endif

if !exists('g:cgtest_build_dir')
	let g:cgtest_build_dir = "./debug"
endif

function! CGTestAll()
	execute "!ctest -T "
endfunction

function! CGTestRegex(regex)
	execute "!ctest -R " . a:regex
endfunction


function! CGTestResultRefresh()
	if len(g:cgtest#tests) == 1
		call CGTestInfoRefresh()
	endif

	if len(g:cgtest#tests) > 1
		if filereadable("./Testing/TAG")
			let tagcontent = readfile ("./Testing/TAG")

			let g:cgtest#tag = tagcontent[0]
			let g:cgtest#tagtype = tagcontent[1]

			let path = "./Testing/" . g:cgtest#tag

			if filereadable( path . "/Test.xml")
				let testxmlcontent = join(readfile (path . "/Test.xml"),'\n')
				let sitecontent = matchstr(testxmlcontent, '<Site.\{-}>')
				"let testingcontent = matchstr(testxmlcontent, "<Testing>.\{-}</Testing>")
				let testscontents = split(matchstr(testxmlcontent, "<Test Status.\*</Test>"), "</Test>")
				for testcont in testscontents
					let name = matchstr(testcont, '<Name>.\{-}<')[6:-2]
					let status = split(matchstr(testcont, '<Test Status=".\{-}"'), '"')[1]
					let completion = split(matchstr(testcont, '<NamedMeasurement type="text/string" name="Completion Status">.\{-}</Value>'), '<Value>')[1][0:-9]
					let time = split(matchstr(testcont, '<NamedMeasurement type="numeric/double" name="Execution Time">.\{-}</Value>'), '<Value>')[1][0:-9]
					let output = split(matchstr(testcont, '<Measurement>.\{-}</Value>'), '<Value>')[1][0:-9]

					" Store results in the variable
					let testpos = g:cgtest#testnum[name]
					"echo "(" . testpos . ")" . name . " " . completion . " " . status . " " . time
					let g:cgtest#tests[testpos].status = status
					let g:cgtest#tests[testpos].completion = completion
					let g:cgtest#tests[testpos].time = time
					let g:cgtest#tests[testpos].output = output
				endfor
			endif
			if filereadable( path . "/Coverage.xml")
				let covxmlcontent = readfile (path . "/Coverage.xml")
				let g:cgtesttotalcov = split(covxmlcontent[-6], "<PercentCoverage>")[1][0:-19]
			endif
		endif
	else
		echo "Could not find tests meta data. Make sure to set"
	endif
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
				let g:cgtest#tests[testnum].name = elements[2]
				let g:cgtest#testnum[elements[2]] = testnum
			else
				let testnum = substitute(elements[0], ":", "", "")
				if grab_envs == 0
					if elements[1] == "Test"
						call add(g:cgtest#tests, { "cmd" : join(elements[3:-1], " ") } )
						let g:cgtest#tests[testnum].env = {}
					elseif elements[1] == "Environment"
						let grab_envs = 1
					endif
				else
					let envval = split(join(elements[1:-1], ' '), "=")
					let g:cgtest#tests[testnum]["env"][envval[0]] = envval[1]
				endif
			endif
		endif
	endfor
endfunction

function! CGTestRefresh()
	execute "!ctest --timeout 20 -D Experimental"
endfunction

function! CGTestResults()
	call CGTestResultRefresh()
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
	syntax keyword GTTESTERROR failed timeout
	syntax keyword GTTESTPASSED passed

	if exists('g:cgtesttotalcov')
		call append(0, "------------------- CGTest (" . g:cgtesttotalcov . "% coverage) -------------------" )
	else
		call append(0, "------------------- CGTest -------------------" )
	endif
	call append(line('$'), "# Test_Name Status Cover Exec_Time" )
	for test in g:cgtest#tests[1:-1]
		if has_key(test, "name")
			let stat = get(test, "status", "not_runned")
			let cov = get(test, "coverage", "--")
			let compicon = get(test, "completion", "--")[0]

			call append(line('$'), compicon . " ". test.name . " " . stat . " " . cov . " " . test.time . "s"   )
			"let test_text = get(test, "output", "test not run")
			"call append(line('$'), test_text )
			"execute line('$') - len(test_text) . "," line('$') . "fold"
		endif
	endfor
	execute "2d"
	"silent foldclose!
	if exists(':Tab')
		execute "2," . line('$') . "Tab / "
	endif
	setlocal nomodifiable
endfunction

function! CGTest()
	call CGTestInfoRefresh()
	call CGTestRefresh()
	call CGTestResults()
endfunction

nnoremap <leader>cgt :call CGTest()<CR>

call CGTestInfoRefresh()

hi GTTESTERROR  guifg=NONE guibg=#FF2222 gui=NONE ctermfg=white ctermbg=red   cterm=NONE
hi GTTESTPASSED guifg=NONE guibg=#22FF22 gui=NONE ctermfg=black ctermbg=green cterm=NONE

command! CGTest call CGTest()
command! CGTestAll call CGTestAll()
command! CGTestRefresh call CGTestRefresh()
command! CGTestResultRefresh call CGTestResultRefresh()
command! CGTestInfoRefresh call CGTestInfoRefresh()
command! CGTestResults call CGTestResults()
command! -nargs=1 CGTestR call CGTestRegex(<f-args>)
command! -nargs=1 CGTestRegex call CGTestRegex(<f-args>)

