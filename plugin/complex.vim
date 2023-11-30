if exists('g:loaded_complex') | finish | endif
let g:loaded_complex = 1

command! ComplexFunc lua require("complex").calculate_func_complexity()
