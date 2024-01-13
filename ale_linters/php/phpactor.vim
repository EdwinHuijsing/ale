" Author: Arizard <https://github.com/Arizard>
" Description: PHPactor integration for ALE
" Note: initial code has been copied from langserver.vim

let g:ale_php_phpactor_executable = get(g:, 'ale_php_phpactor_executable', 'phpactor')
call ale#Set('php_phpactor_use_global', get(g:, 'ale_use_global_executables', 0))

" Get project root;  Assume there is an composer file or a git directory in the root
" return an empty string if there is not valid root, this prevents the
" language-server from starting
function! ale_linters#php#phpactor#GetProjectRoot(buffer) abort
    let l:composer_path = ale#path#FindNearestFile(a:buffer, 'composer.json')
    let l:file_mappings = ale#GetFilenameMappings(a:buffer, 'phpactor')

    if (!empty(l:composer_path))
        let l:path = ale_linters#php#phpactor#Mapping(l:composer_path, l:file_mappings )

        if empty(l:path)
            let l:path = fnamemodify(l:composer_path, ':h')
        endif

        return l:path
    endif

    let l:git_path = ale#path#FindNearestDirectory(a:buffer, '.git')

    if (!empty(l:git_path))
        let l:path = ale_linters#php#phpactor#Mapping(l:git_path, l:file_mappings )

        if empty(l:path)
            let l:path = fnamemodify(l:git_path, ':h:h')
        endif

        return l:path
    endif

    return ''
endfunction

" Convert full to remote path, if not found empty is returned
function! ale_linters#php#phpactor#Mapping(filename, filename_mappings) abort
    if empty(a:filename_mappings)
        " No mapping to return
        return ''
    endif

    for [l:mapping_from, l:mapping_to] in a:filename_mappings
        let l:mapping_from = ale#path#Simplify(l:mapping_from)

        if a:filename[:len(l:mapping_from) - 1] is# l:mapping_from
            return l:mapping_to
        endif
    endfor

    " Nothing found to return
    return ''
endfunction

call ale#linter#Define('php', {
\   'name': 'phpactor',
\   'lsp': 'stdio',
\   'executable': {buffer -> ale#path#FindExecutable(buffer, 'php_phpactor', [
\       'vendor/bin/phpactor',
\       'phpactor'
\   ])},
\   'command': '%e language-server',
\   'project_root': function('ale_linters#php#phpactor#GetProjectRoot'),
\})
