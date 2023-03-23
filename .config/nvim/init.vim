" Options
set background=dark
set cc=150
set clipboard=unnamedplus
set completeopt=noinsert,menuone,noselect
set cursorline
set encoding=utf-8
set hidden
set hlsearch
set inccommand=split
set incsearch
set mouse=a
set nocompatible
set number
set showmatch
set splitbelow splitright
set ttimeoutlen=0
set ttyfast
set t_Co=256
set wildmode=longest,list
set wildmenu

" Tabs size
set expandtab
set shiftwidth=2
set tabstop=2

" Italics
let &t_ZH="\e[3m"
let &t_ZR="\e[23m"

filetype plugin indent on
syntax enable
let maplocalleader = "."

" Plugins
call plug#begin('$XDG_DATA_HOME/nvim/plugged')

    " Appearance
    Plug 'olimorris/onedarkpro.nvim'
    Plug 'ryanoasis/vim-devicons'
    Plug 'junegunn/goyo.vim'

    " Utilities
    "Plug 'sheerun/vim-polyglot'
    Plug 'jiangmiao/auto-pairs'
    Plug 'preservim/nerdtree'

    " Typesetting
    Plug 'lervag/vimtex'
        let g:Tex_DefaultTargetFormat = 'pdf'
        let g:tex_conceal = ''
        let g:tex_flavor = 'latex'
        let g:vimtex_indent_enabled = 1
        let g:vimtex_compiler_progname = 'nvr'
        let g:vimtex_complete_close_braces = 1
        let g:vimtex_fold_enabled = 0
        let g:vimtex_quickfix_mode = 2
        let g:vimtex_view_automatic = 1
        let g:vimtex_view_enabled = 1
        let g:vimtex_view_general_viewer = 'zathura'
        let g:vimtex_view_method = 'zathura'
        "let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
    Plug 'plasticboy/vim-markdown'
        " Disable math tex conceal feature (not good)
        let g:vim_markdown_math = 1
        let g:vim_markdown_folding_disabled = 1
        let g:vim_markdown_frontmatter = 1
        let g:vim_markdown_conceal = 0
	      let g:vim_markdown_conceal_code_blocks = 0
    Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
	      let g:mkdp_auto_start = 0
	      let g:mkdp_auto_close = 1
	      let g:mkdp_theme = 'dark'
    
    " Snippets
    Plug 'SirVer/ultisnips'
        let g:UltiSnipsExpandTrigger="<tab>"
        let g:UltiSnipsJumpForwardTrigger="<tab>"
        let g:UltiSnipsJumpBackwardTrigger="<c-z>"
    Plug 'honza/vim-snippets'

call plug#end()

colorscheme onedarkpro

" NERDTree
let NERDTreeShowHidden=1

""" [Re]mappings
nnoremap <C-s> :w<CR>
nnoremap <C-w> :bd<CR>
nnoremap <C-q> :q!<CR>
nnoremap <F4> :sp<CR>:terminal<CR>
nnoremap <C-p> <Plug>MarkdownPreviewToggle<CR>
"nnoremap <C-p> :call VimtexCompile()<CR>
"nnoremap <C-p> :call LatexPreviewZathura()<CR>

inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi

""" Auto Commands
"augroup latex
"    autocmd BufWrite *.py call ...
"augroup end

""" FUNCTIONS
" LaTeX preview with Zathura
"function! LatexPreviewZathura()
"	let fullPath = expand("%:p")
"	let pdfFile = substitute(fullPath, ".tex", ".pdf", "")
"	execute "silent !zathura '" . pdfFile . "' &"
"endfunction
