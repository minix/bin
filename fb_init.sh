#!/bin/sh 

home_dir="/home/minix"
cat << EOF >> /root/.cshrc
setenv PACKAGESITE ftp://ftp6.tw.freebsd.org/FreeBSD/ports/i386/packages-9.0-release/Latest/"
alias ll     ls -l 
alias ls     ls -G 
alias la     ls -AG
alias li     ls -iG
setenv LESS_TERMCAP_mb $'\E[01;31m'
setenv LESS_TERMCAP_md $'\E[01;31m'
setenv LESS_TERMCAP_me $'\E[0m' 
setenv LESS_TERMCAP_se $'\E[0m'
setenv LESS_TERMCAP_so $'\E[01;44;33m'
setenv LESS_TERMCAP_ue $'\E[0m'
setenv LESS_TERMCAP_us $'\E[01;32m'
EOF

. /root/.cshrc

vim_path=`which vim`

if [ -z ${vim_path} ]; then
     echo "Vim don't install in the system,Now will installing , please wait for moment"
     pkg_add -r ${vim_app}-lite
else
     echo "alias vi ${vim_path}" >> /root/.cshrc
fi

pkg_add -r sudo
pkg_add -r zsh

#/etc/ttys
sed -i ".backup" '35,40 s/on/off/g' /etc/ttys  
#/etc/login.conf
sed -i ".backup" 's/passwd_format=md5/passwd_format=blf/g' /etc/login.conf
#/etc/sysctl.conf
sed -i ".backup" '$a\
hw.syscons.bell=0' /etc/sysctl.conf
cap_mkdb /etc/login.conf
#/etc/auth.conf
echo "crypt_default = blf" >> /etc/auth.conf
#/etc/gettytab
sed '39 s:%s/%m (%h) (%t): Welcome, Minix!:' /etc/gettytab
#/etc/COPYRIGHT
touch /etc/COPYRIGHT
#/etc/rc.conf
cat >> /etc/rc.conf << 'EOF'
sendmail_enable="NO"
sendmail_submit_enable="NO"
sendmail_outbound_enable="NO"
sendmail_msp_queue_enable="NO"

syslogd_enable="YES"
syslogd_flags="-ss"

clear_tmp_enable="YES"
update_motd="NO"

check_quotas="NO"

if_up_delay="5"
EOF
#/etc/motd
cat > /etc/motd << 'EOF'
              ,        ,
             /(        )`
             \ \___   / |
             /- _  `-/  '
            (/\/ \ \   /\
            / /   | `    \
            O O   ) /    |
            `-^--'`<     '
           (_.)  _  )   /
            `.___/`    /
              `-----' /
<----.     __ / __   \
<----|====O)))==) \) /====
<----'    `--' `.__,' \
              |        |
               \       /       /\
          ______( (_  / \______/
        ,'  ,-----'   |
        `--{__________)
EOF

pw adduser minix -g wheel -d ${home_dir} -s /bin/sh
chpass -p '$1$GDYfCNn4$cUY0zi4kuog.2gJEV0.HI1' minix
if [ -e ${home_dir} ]; then
  cat > ${home_dir}/.zsh << 'EOF'
# Example .zshrc file for zsh 4.0
#
# .zshrc is sourced in interactive shells.  It
# should contain commands to set up aliases, functions,
# options, key bindings, etc.
#

# THIS FILE IS NOT INTENDED TO BE USED AS /etc/zshrc, NOR WITHOUT EDITING

# Set up aliases
alias j=jobs
alias ll='ls -l'
alias vi=vim
alias ls='ls -G'
alias la='ls -AG'
alias li='ls -iG'
alias html='/home/minix/bin/html.sh'

export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

#bindkey '^xp' history-beginning-search-backward
#bindkey '^xn' history-beginning-search-forward

set noclobber
# Set prompts
PROMPT='%F{yellow}IN%f%F{red}[%~]%f%F{blue}>%f%F{white}>%f%F{yellow}>%f'    # default prompt
#RPROMPT='%F{red} %~%f'     # prompt for right side of screen

export LANG=en_US.UTF-8
export LC_CTYPE=zh_CN.UTF-8
EOF

cat > ${home_dir}/.vimrc << 'EOF'
set history=50          " keep 50 lines of command line history
set ruler               " show the cursor position all the time
set showcmd             " display incomplete commands
set incsearch           " do incremental searching

syntax on
set number
set tabstop=2
set shiftwidth=2
"set encoding=utf-8
set showcmd
set autoindent
set smartindent
set autoread

filetype plugin on
filetype indent on

"nmap <F8> <ESC>NERDTreeToggle<RETURN>
"nmap <F7> :NERDTree <RETURN>
"nmap st :Tlist <RETURN>
"
inoremap ( ()<ESC>i
inoremap ) <c-r>=ClosePair(')')<CR>
inoremap { {}<ESC>i
inoremap } <c-r>=ClosePair('}')<CR>
inoremap [ []<ESC>i
inoremap ] <c-r>=ClosePair(']')<CR>
"inoremap < <><ESC>i
"inoremap > <c-r>=ClosePair('>')<CR>
inoremap ' <c-r>=CompleteQuote("'")<CR>
inoremap " <c-r>=CompleteQuote('"')<CR>
"inoremap <BS> <ESC>:call RemovePairs()<CR>a
"
function! OpenPair(char)
    let PAIRs = {
                \ '{' : '}',
                \ '[' : ']',
                \ '(' : ')',
                \ '<' : '>'
                \}
    if line('$')>2000
        let line = getline('.')

        let txt = strpart(line, col('.')-1)
    else
        let lines = getline(1,line('$'))
        let line=""
        for str in lines
            let line = line . str . "\n"
        endfor

        let blines = getline(line('.')-1, line("$"))
        let txt = strpart(getline("."), col('.')-1)
        for str in blines
            let txt = txt . str . "\n"
        endfor
    endif
    let oL = len(split(line, a:char, 1))-1
    let cL = len(split(line, PAIRs[a:char], 1))-1

    let ol = len(split(txt, a:char, 1))-1
    let cl = len(split(txt, PAIRs[a:char], 1))-1

    if oL>=cL || (oL<cL && ol>=cl)
        return a:char . PAIRs[a:char] . "\<Left>"
    else
        return a:char
    endif
endfunction

function ClosePair(char)
    if getline('.')[col('.') - 1] == a:char
        return "\<Right>"
    else
        return a:char
    endif
endf
function! CompleteQuote(quote)
    let ql = len(split(getline('.'), a:quote, 1))-1
    let slen = len(split(strpart(getline("."), 0, col(".")-1), a:quote, 1))-1
    let elen = len(split(strpart(getline("."), col(".")-1), a:quote, 1))-1
    let isBefreQuote = getline('.')[col('.') - 1] == a:quote

    if '"'==a:quote && "vim"==&ft && 0==match(strpart(getline('.'), 0, col('.')-1), "^[\t ]*$")
" for vim comment.
        return a:quote
    elseif "'"==a:quote && 0==match(getline('.')[col('.')-2], "[a-zA-Z0-9]")
" for Name's Blog.
        return a:quote
    elseif (ql%2)==1
" a:quote length is odd.
        return a:quote
    elseif ((slen%2)==1 && (elen%2)==1 && !isBefreQuote) || ((slen%2)==0 && (elen%2)==0)
        return a:quote . a:quote . "\<Left>"
    elseif isBefreQuote
        return "\<Right>"
    else
        return a:quote . a:quote . "\<Left>"
    endif
endfunction

function! RemovePairs()
    let s:line = getline(".")
    let s:previous_char = s:line[col(".")-1] " 取得当前光标前一个字符

    if index(["(", "[", "{"], s:previous_char) != -1
        execute "normal! v%xi"
    else
        execute "normal! a\<BS>"
    end
endfunction
EOF
