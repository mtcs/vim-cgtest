nnoremap <leader>cgt :call CGTest()<CR>

command! CGTest call CGTest()
command! -nargs=1 CGTestR call CGTestRegex(<f-args>)

