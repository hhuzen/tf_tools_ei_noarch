  
" see http://guts.xxxxx.nl/gutswiki/index.php/Vim/IDE
"
" on unix, add in your .vimrc:
"   if filereadable( $HOME."/.vim/vim_as_ide.vim") 
"      source $HOME/.vim/vim_as_ide.vim
"   endif
"
"
"
set guifont=Monospace\ 8

" Toggle colorscheme
"
" some versions/builds of vim do not have g:colors_name
" some color files need it
" however on cygwin: the g:colors_name must be valid
if !exists("g:colors_name")
    let cs=''
    redir => cs
      silent! exe "colorscheme"
    redir END
    let g:colors_name= substitute( cs, "^.", "" , "")
    let g:colors_name_fix=''
endif

function! SetColorsName()
  if exists("g:colors_name_fix")
    let cs=''
    redir => cs
      silent! exe "colorscheme"
    redir END
    let g:colors_name= substitute( cs, "^.", "" , "")
  endif
endfunction


function! F6ColorScheme(what)
  if a:what== 'COLORS' 
    execute "COLORS" 
    call SetColorsName()
  endif
  if a:what == 'bgtoggle'
    if  &background=="dark" 
      set background=light
      highlight Normal guibg=white guifg=black ctermbg=white ctermfg=black
    else
      set background=dark
      highlight Normal guibg=black guifg=white ctermbg=black ctermfg=white
    endif
    let cs=''
    redir => cs
      silent! exe "colorscheme"
    redir END
    let cs= substitute( cs, "^.", "" , "")
    echom "set background=".&background ." colorscheme=" . cs
  endif
endfunction

" setup T
let Tlist_Use_Right_Window = 1
let Tlist_GainFocus_On_ToggleOpen = 1
" For taglist outline
function! F7TagBarToggle()
  execute "TlistToggle"
endfunction

" TabToggle allow toggling between local and default mode
"source code indentation - default tabstop 2, expandtab 
"virtual tabstops using spaces - toggle with F9
"set expandtab	  tabs are needed in makefiles
let my_tab=2
execute "set shiftwidth=".my_tab
execute "set softtabstop=".my_tab
set expandtab
let my_F9=1
function! F9TabToggle()
    if g:my_F8 == 0
      let g:my_F8 = 1
      set shiftwidth=8
      set softtabstop=0
      set tabstop=8
      set noexpandtab
      echo 'set noexpandtab - use real tabs(8)'
    elseif g:my_F8 == 1
      let g:my_F8 = 2
      set shiftwidth=4
      set softtabstop=0
      set tabstop=4
      set noexpandtab
      echo 'set noexpandtab - use real tabs(4)'
    elseif g:my_F8 == 2
      let g:my_F8 = 3
      set shiftwidth=2
      set softtabstop=0
      set tabstop=2
      set noexpandtab
      echo 'set noexpandtab - use real tabs(2)'
    elseif g:my_F8 == 3
      let g:my_F8 = 1
      execute "set shiftwidth=".g:my_tab
      execute "set softtabstop=".g:my_tab
      set tabstop=8
      set expandtab
      echo 'set expandtab - replace tabs with spaces'
    endif
endfunction

" For mouse select/copy/paste actions
let my_F8=1
set nopaste
set number
set norelativenumber
function! F8PasteNumberToggle()

    if g:my_F8 == 0
      let g:my_F8 = 1
      "echo '1: set goto to IDE mode : nopaste, absolute number, signature'
      set nopaste
      set number
      set norelativenumber
      call signature#TempReEnable()
    elseif g:my_F8 == 1
      let g:my_F8 = 2
      "echo '2: set goto to IDE mode : nopaste, relative number, signature'
      set nopaste
      set number
      set relativenumber
    elseif g:my_F8 == 2
      let g:my_F8 = 0
      "echo '0 set goto to copy/paste mode : paste, nonumber, nosignature'
      set paste
      set nonumber
      set norelativenumber
      call signature#TempDisable()
    endif
endfunction


let F1helpstate=0

" F1HelpHelp
function! F1HelpHelp()
  if g:F1helpstate == 6 
    echo "end"
    let g:F1helpstate = 0
    return
  endif

  let g:F1helpstate = g:F1helpstate + 1 

  echo " |-----------------------------------------------------------------------------------------------------------|"
  echo " |                                                  VIM as IDE                                               |"
  echo " |-----------------------------------------------------------------------------------------------------------|"

  if g:F1helpstate == 1 
    echo " |----------------------------------------------------help---------------------------------------------------|"
    echo "  <Leader>=space"
    echo "  <Leader>hh : This handyhelp info"
    echo "  <Leader>sc : SyntasticCheck syntax checker"
    echo "  <Leader>st : SyntasticCheck-toggle (disable)"
    echo "  <Leader>bfj : Syntax beautifier javascript"
    echo "  <Leader>bfx : Syntax beautifier xml"
    echo "  :set all (show all options)"
    echo "  "
    echo "  windows:      <c-w>s/n : new window hor split on current/new file"
    echo "                <c-w>v/m : new window vert split on current/new file"
    echo "                <c-w>w/<c-w>hjkl next/left-up-down-right window "
    echo "                <c-w>q : close window "
    echo "  tabs:"
    echo "                <c-t>t : list tabs,              <c-t>v : new tab"
    echo "                <c-t>h/l: left/right tab         <c-t>c : close tab"
    echo "  "
    echo "  completion:   <c-x> start: <c-e> cancel, <c-n> next, <c-p> prev, type to select"
    echo "  key mapping:  :imap :nmap :vmap "
    echo "  " 
    echo "  :Q      : quit all" 
    echo "  :QQ     : quit all - no save" 
    echo "  :Mktags : create ctags" 
    echo "  :Rmtags : remove ctags" 
    echo "  "
    echo "  <F1> : 6-toggle this help/messages/registers/buffers/marks/tabs"
    echo "  <F3> : quit all, no save"
    echo "  <F4> : enter NERDtree mode"
    echo "  <F5> : enter NETRW mode"
    echo "        qb = list bookmark"
    echo "        <index>gb = goto bookmark <index>"
    echo "  <F6><S-F6> : toggle background dark/light / ScrollColors-menu"
    echo "  <F7> : toggle taglist outliner"
    echo "  <F8> : 3-toggle : absnumber,nopaste/relnumber,nopaste/nonumber,paste"
    echo "  <F9> : 2-toggle : expandtab/noexpandtab"
    echo "  <F10>: codepage-toggle : binary transfer vs netrw_ftp_enc_toggle"
    echo " |--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|"
    echo " |   F1   |   F2   |   F3   |   F4   |   F5   |   F6   |   F7   |   F8   |   F9   |  F10   |  F11   |  F12   |"
    echo " |  help  |  help  |  QUIT  |nerdtree| netrw  | colors |taglist | paste  |  tabs  |        |        |        |"
  elseif g:F1helpstate == 2
    echo " |--------------------------------------------------messages-------------------------------------------------|"
    execute "messages"
  elseif g:F1helpstate == 3
    echo " |--------------------------------------------------registers------------------------------------------------|"
    execute "registers"
  elseif g:F1helpstate == 4
    echo " |---------------------------------------------------buffers-------------------------------------------------|"
    execute "buffers"
  elseif g:F1helpstate == 5
    echo " |----------------------------------------------------marks--------------------------------------------------|"
    execute "marks"
  elseif g:F1helpstate == 6
    echo " |-----------------------------------------------------tabs--------------------------------------------------|"
    execute "tabs"
  endif 
  echo " |--------------------------------------------------F3 to end------------------------------------------------|"
endfunction

function! F3Exit()
  if g:F1helpstate == 0
    call inputsave()
    let qinput = input("Press <F3><cr> to quit")
    call inputrestore()
    if ( qinput =~ "<F3>" ) 
      call feedkeys(":qa!\n")    
    endif
  endif
  let g:F1helpstate = 0
endfunction




let nrt_mode=''
let in_nrt_mode=0
function! F4NERDtreeToggle()
    if ( g:nrt_mode == 'R' ) 
      echo 'Sorry: already in NETRW mode'
      "reset to allow force
    let g:nrt_mode=''
  else
    let g:nrt_mode='T'

    if g:in_nrt_mode == 0 
      echo 'Entering NERDtree mode.'
      execute "NERDTree"
      let g:in_nrt_mode = 1 
    else
      execute "NERDTreeToggle"
      let g:in_nrt_mode = 0 
    endif
  endif
endfunction

function! F5EnterNR()
  if ( g:nrt_mode == 'T' ) 
    echo 'Sorry: already in NERDtree mode'
    "reset to allow force
    let g:nrt_mode=''
  else
    echo 'Entering NETRW mode.'
    let g:loaded_nerdtree_autoload = 1
    let loaded_nerd_tree = 1
    execute "Explore"
    let g:nrt_mode='R'
  endif
endfunction


"===== general
  set encoding=utf-8
  set t_Co=256
  filetype on
  filetype indent on
  filetype plugin on
  set number
  set ruler 
  set nocompatible
  let mapleader=' '

  nnoremap <F9> :call F9TabToggle()<CR>
  nnoremap <F8> :call F8PasteNumberToggle()<CR>
  nnoremap <F7> :call F7TagBarToggle()<CR>
  nnoremap <F6> :call F6ColorScheme("bgtoggle")<CR>
  nnoremap <S-F6> :call F6ColorScheme("COLORS")<CR>

  " syntax highlighting
  syntax on
  set backspace=indent,eol,start

  "use ctags
  set tags=./tags,tags
  command! Mktags !ctags -R .
  command! Rmtags !rm -f tags
  " now we can
  "  - use ^] to jump to tag under cursor
  "  - use g^] for ambiguous tags
  "  - use ^t to jump back


  " my own commands
  "help
  command -nargs=* HH :call F1HelpHelp()
  command -nargs=* Q  :execute "qa"
  command -nargs=* QQ  :execute "qa!"
  nnoremap <silent> <F1>  :call F1HelpHelp()<CR>
  nnoremap <silent> <F2>  :call F1HelpHelp()<CR>
  nnoremap <silent> <F3>  :call F3Exit()<CR>
  

"quick command to start NERDTree
   nnoremap <silent> <F4> :call F4NERDtreeToggle()<CR>
"quick command to start netrw explorer, and make its bookmarks available
   nnoremap <silent> <F5> :call F5EnterNR()<CR>

"quick command to start syntastic syntax check 
   nnoremap <silent> <Leader>sc :SyntasticCheck<CR>
   nnoremap <silent> <Leader>st :SyntasticToggle<CR>
"quick command to start jsbeautify
   nnoremap <silent> <Leader>bfj :call Beautifier()<CR>

"search highlighting
  set incsearch
  set hlsearch
  if has('gui_running')
    hi Search guibg=peru guifg=wheat
  else
    hi Search cterm=NONE ctermfg=white ctermbg=blue
  endif

"====airline plugin 
set laststatus=2               " enable airline even if no splits
let g:airline#extensions#nrrwrgn#enabled = 0  " troublesome plugin
let g:Powerline_symbols = 'fancy'
set fillchars+=stl:\ ,stlnc:\
let g:Powerline_mode_V="V·LINE"
let g:Powerline_mode_cv="V·BLOCK"
let g:Powerline_mode_S="S·LINE"
let g:Powerline_mode_cs="S·BLOCK"
   
"====solarized colorscheme
  set t_Co=256
  let g:solarized_termtrans = 1
  let g:solarized_visibility = "high"
  let g:solarized_contrast = "high"
  let g:solarized_termcolors=256

"====netrw ftp for mainframe access
" examples:
"  - edit files
"    vim "ftp://mach.xxxxx.nl//u/axxgxxx/iiii00/t.sh"
"    vim "ftp://mach.xxxxx.nl/'AxxGxxx.IIII00.S0(SDF)'"
"  - browse directory 
"    vim "ftp://mach.xxxxx.nl//u/xxgxxx/iiii00/"
"    vim "ftp://mach.xxxxx.nl/'AxxGxxx.IIII00.S0'"
"
" you can preset bookmarks in .vim/.netrwbook, like
" let g:netrw_bookmarklist= ['ftp://mach.xxxxx.nl/''AxxGxxx.IIII00.S0.WP.OCYBTU''', 'ftp://mach.xxxxx.nl/''AxxGxxx.IIII00.S0.WP.XXX''']
" 
  " configuration:
  let netrw_ftpmode="ascii"
  " suppress the netrw errorwindow
  let netrw_use_errorwindow=0
  " codepage conversion for USS, traditionally network encoding is latin1 =
  " ISO8859-1
  "  codepage              , ftp mode, ftp extra command
  let netrw_ftp_enc_toggle= [ 
\    ['IBM-1047',  'ascii',  'quote site sbd=(IBM-1047,ISO8859-1)' ],
\    ['IBM-1140',  'ascii',  'quote site sbd=(IBM-1140,ISO8859-1)' ],
\    ['IBM-037',   'ascii',  'quote site sbd=(IBM-037,ISO8859-1)' ],
\    ['IBM-500',   'ascii',  'quote site sbd=(IBM-500,ISO8859-1)' ],
\    ['ISO8859-1', 'binary', '' ],
\    ['UTF-8',     'binary', '' ]
\ ]
  " which servers to recognize as IBM FTP servers (commalist)
  let netrw_ftp_ibm_server_list="mach.xxxxx.nl,mach.xxxxx.nl"    

  " Hit enter in the file browser to open the selected
  " file with :vsplit to the right of the browser.
  "  g:netrw_browse_split*
  "  when browsing, <cr> will open the file by:
  "    =0: re-using the same window
  "    =1: act like "o" horizontally splitting the window first  
  "    =2: act like "v" vertically   splitting the window first  
  "    =3: act like "t" open file in new tab
  "    =4: act like "P" (ie. open previous window)
 
  let g:netrw_browse_split = 2
  let g:netrw_altv = 1
  " Dont! Change directory to the current buffer when opening files.
  "set autochdir
  set path+=**
  set wildmenu
  " now we can:
  " - Hit tab (autocomplete) to :find by partial match, use * to make fuzzy
  "   find
  " - :b on open buffers

"====easymotion
" easymotion highlight colors
hi link EasyMotionTarget Search
hi link EasyMotionTarget2First Search
hi link EasyMotionTarget2Second Search
hi link EasyMotionShade Comment

"====syntastic
"
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

let g:syntastic_perl_checkers = [ 'perl', 'podchecker' ]
let g:syntastic_enable_perl_checker = 1
let g:syntastic_java_checkers = [ 'javac' ]
let g:syntastic_enable_java_checker = 1


"= window navigation
"
nnoremap <silent> <C-W>M  :vnew<CR>
nnoremap <silent> <C-W><C-M>  :vnew<CR>

"= tab navigation
"

nnoremap <silent> <C-T>T  :tabs<CR>
nnoremap <silent> <C-T><C-T>  :tabs<CR>
nnoremap <silent> <C-T>V  :tabnew<CR>
nnoremap <silent> <C-T><C-V>  :tabnew<CR>
nnoremap <silent> <C-T>L  :tabnext<CR>
nnoremap <silent> <C-T><C-L>  :tabnext<CR>
nnoremap <silent> <C-T>H  :tabprev<CR>
nnoremap <silent> <C-T><C-H>  :tabprev<CR>

" tq = close all tabs
let notabs = 0 
nnoremap <silent> <C-T>C :let notabs=!notabs<Bar>:if notabs<Bar>:tabo<Bar>:else<Bar>:tab ball<Bar>:tabn<Bar>:endif<CR>
nnoremap <silent> <C-T><C-C> :let notabs=!notabs<Bar>:if notabs<Bar>:tabo<Bar>:else<Bar>:tab ball<Bar>:tabn<Bar>:endif<CR>

" for using CTLR-[ as help-go-back next to CTRL-] for help-go-forward, but it
" messes up the <Fx> mappings
"nnoremap <C-[> :call feedkeys("\<C-T>")<CR>

"----------------------------------------------------"
" on file open: 
"  - return to last position
"  - or return to 'hiero' word
"
if !exists("g:hiero")
  let hieroword='hiero'
endif

function FindHiero() 
  let ms=''
  redir => ms
    silent! exe '%s/' . g:hieroword . '//gn'
  redir END
  if ms =~ "match"
    execute '/'. g:hieroword
  endif
  redraw!
endfunction
if has("autocmd")
    autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
    autocmd BufReadPost * :call FindHiero()
endif

"----------------------------------------------------"
" on vim start (os390) : redraw screen
" on os390 when starting vim with a filename, some rubbish characters are
" displayed sometimes, which are removed with a redraw
" use the updatetime once for doing an initial redraw 
"  first after 1, then after 100 ms, then fallback to the 4000 ms default and 
"  do nothing
set updatetime=1
function! HookReDraw() 
  if &updatetime<4000
    redraw!
    if &updatetime<100
      set updatetime=100
        "echom "hook redraw set 100 ". &updatetime
    else
      if &updatetime<4000
        set updatetime=4000
      endif  
    endif
  endif
  " some activity te restart the timer?
  call feedkeys("f\e")    
endfunction
autocmd CursorHold * :call HookReDraw()

"----------------------------------------------------"
" on vim start force background depending on
" background setting (in .vimrc)
" else gvim has a grey background
function! HookGuiBg() 
      if &background=="dark"
            highlight Normal guibg=black guifg=white ctermbg=black ctermfg=white
      endif
      if &background=="light"
            highlight Normal guibg=white guifg=black ctermbg=white ctermfg=black
      endif
endfunction
autocmd VimEnter * :call HookGuiBg()

"----------------------------------------------------"
" for matchit - the previous settings does not sustain?
  filetype plugin on

autocmd FileType java setlocal omnifunc=javacomplete#Complete
nmap <F10> <Plug>(JavaComplete-Imports-AddSmart)

"----------------------------------------------------"
" XML formatter
function! DoFormatXML() range
        " Save the file type
        let l:origft = &ft

        " Clean the file type
        set ft=

        " Add fake initial tag (so we can process multiple top-level elements)
        exe ":let l:beforeFirstLine=" . a:firstline . "-1"
        if l:beforeFirstLine < 0
                let l:beforeFirstLine=0
        endif
        exe a:lastline . "put ='</PrettyXML>'"
        exe l:beforeFirstLine . "put ='<PrettyXML>'"
        exe ":let l:newLastLine=" . a:lastline . "+2"
        if l:newLastLine > line('$')
                let l:newLastLine=line('$')
        endif

        " Remove XML header
        exe ":" . a:firstline . "," . a:lastline . "s/<\?xml\\_.*\?>\\_s*//e"

        " Recalculate last line of the edited code
        let l:newLastLine=search('</PrettyXML>')

        " Mark empty lines
        silent! exe ":silent " . a:firstline . ",$s/^[ \t]*$//"
        silent! exe ":silent " . a:firstline . ",$s/^\s*$/<!--magicempty-->/"

        " Execute external formatter
        exe ":silent " . a:firstline . "," . l:newLastLine . "!xmllint --noblanks --format --recover -"

        " Unmark empty lines
        silent! exe ":silent " . a:firstline . ",$s/.*--magicempty--.//"

        " Recalculate first and last lines of the edited code
        let l:newFirstLine=search('<PrettyXML>')
        let l:newLastLine=search('</PrettyXML>')
        
        " Get inner range
        let l:innerFirstLine=l:newFirstLine+1
        let l:innerLastLine=l:newLastLine-1

        " Remove extra unnecessary indentation
        exe ":silent " . l:innerFirstLine . "," . l:innerLastLine "s/^  //e"

        " Remove fake tag
        exe l:newLastLine . "d"
        exe l:newFirstLine . "d"

        " Put the cursor at the first line of the edited code
        exe ":" . l:newFirstLine

        " Restore the file type
        exe "set ft=" . l:origft
endfunction
command! -range=% FormatXML <line1>,<line2>call DoFormatXML()

nmap <silent> <leader>bfx :%FormatXML<CR>
vmap <silent> <leader>bfx :FormatXML<CR>
" /XML formatter

"----------------------------------------------------"
" vim-codefmt
set nocompatible | filetype indent plugin on | syn on
set runtimepath+=$HOME/.vim/vam/vim-addon-manager
call vam#ActivateAddons(['vim-codefmt', 'vim-glaive'])

augroup autoformat_settings
  autocmd FileType bzl AutoFormatBuffer buildifier
  autocmd FileType c,cpp,proto,javascript AutoFormatBuffer clang-format
  autocmd FileType dart AutoFormatBuffer dartfmt
  autocmd FileType go AutoFormatBuffer gofmt
  autocmd FileType gn AutoFormatBuffer gn
  autocmd FileType html,css,sass,scss,less,json AutoFormatBuffer js-beautify
  autocmd FileType java AutoFormatBuffer google-java-format
  autocmd FileType python AutoFormatBuffer yapf
  " Alternative: autocmd FileType python AutoFormatBuffer autopep8
  autocmd FileType rust AutoFormatBuffer rustfmt
  autocmd FileType vue AutoFormatBuffer prettier
augroup END

call glaive#Install()
Glaive codefmt google_java_executable='java -jar /home/ONT/iiii00/.vim/java/google-java-format-1.7-all-deps.jar'
" /vim-codefmt


