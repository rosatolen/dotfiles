### 1Password

# Only do when I need my GPG password
#eval "export OP_SESSION=$(op signin my --raw)"

### go projet

alias goexp='cd ~/repos/expungements/'
alias goint='cd ~/repos/integration-services/'

### Experimental
alias ping='prettyping --nolegend'

### FZF
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--bind='ctrl-j:execute(vim {})+abort,ctrl-o:execute(vim {})+abort'"
alias o="fzf --preview 'bat --color \"always\" {}'"
export FZF_CTRL_R_OPTS="--reverse --bind='ctrl-j:execute(echo {})+abort'"

#alias find='fd'

alias du='ncdu --color dark -rr -x --exclude .git --exclude node_modules'

### General

#export PS1='[\u@\h \W]\$ '
export PS1='[\D{%F %T %Z}] \W \$ '

termbell() {
    gsettings set org.gnome.desktop.wm.preferences audible-bell false
    gsettings set org.gnome.desktop.wm.preferences visual-bell false
}

lock() {
    . /home/rosatolen/configs/pretty-lock.sh
}

_sudo () {
    ARGS="'$@'"
    printf 'Running: sudo %s in %s\n' "$ARGS" "$PWD"
    sudo "$@"
}

### Ack

ackjava() {
    ack -f --type=java | ack --files-from=- "$@"
}

ackjson() {
    ack -f --type=json | ack --files-from=- "$@"
}

### Rg

alias rg='rg --hidden'

### Find

fzvi() {
    vim "$(fzf)"
}

fa() {
    FILE="${1:?'Usage fa <name>'}"
    _sudo find / -name "*$FILE*" 2>/dev/null
}

fl() {
    printf 'Running: find . -name *%s* 2>/dev/null\n' "${1:?'Usage: fl <name>'}"
    find . -name "*$1*" 2>/dev/null
}

fexact() {
    printf 'Running: find . -name *%s* 2>/dev/null\n' "${1:?'Usage: fl <name>'}"
    find . -name "$1" 2>/dev/null
}

### Systemd

systemctl_list() { systemctl list-unit-files; }

### Vim

export EDITOR=vim
export VISUAL=vim

vs() { vim -S Session.vim; }

v() { vim .; }

vi() { vim "$@"; }

ev() { vim ~/.vimrc; }

# For piping input you wish to read with syntax highlighting
vimro() { vim -R -; }

vimpack() {
    PACK_DIR=~/.vim/pack/
    if cd "$PACK_DIR"; then
        echo "You are in $PWD. Install packages here. The directory heirarchy scheme is:"
        echo "\"$HOME/.vim/pack/<author>/[start,opt]/<plugin_name>/[plugin,syntax]/<plugin_name>.vim\""
        echo "For more information about package installation, check :h packages"
    else
        printf 'The vim plugin directory (%s) does not exist. Please create it first. \n' "$PACK_DIR"
    fi
}

newctags() {
    printf 'Generating tags file for this directory: %s\n' "$PWD"
    ctags -R .
}

### Sed

dline() {
    : "${1:?'Usage: dline <line number> <file>'}"
    : "${2:?'Usage: dline <line number> <file>'}"
    sed -i "$1d" "$2"
}

### Curl
curlFile() {
    curl -O "${1:?'Usage: curlFile <URL>'}"
}

curlTo() {
    curl -o "${1:?'Usage: curlFile <output name> <URL>'}" "${2:?'Usage: curlFile <output name> <URL>'}"

}

### Shell

shell_all_funcs() {
    declare -f
}

### Profile

# shellcheck source=/dev/null
ep() { vim ~/.profile; . ~/.profile; }

# shellcheck source=/dev/null
newp() { . ~/.profile; }

profilecheck() { shellcheck -s sh ~/.profile; }

### Docker

sdocker() { _sudo docker "$@"; }

dubuntu() { docker run --rm -it ubuntu:trusty; }

dprecise() { docker run --rm -it ubuntu:precise; }

dkill() { docker rm  -f "${1:?'Usage: dkill <name>'}";}

dockercleanall() {
    docker system prune -a
}

### Kubectl
kapplyf() {
    kubectl apply -f "${1:?'kapplyf <filename>'}"
}

kbabysit() {
    # TODO: replace with 'watch -n'
    while true; do
        clear
        date
        pods
        nodes
        sleep 5
    done
}

kdelevicted() {
    kubectl get pods --all-namespaces -ojson | \
        jq -r '.items[] | select(.status.reason!=null) | select(.status.reason | contains("Evicted")) | .metadata.name + " " + .metadata.namespace' | \
        xargs -n2 -l bash -c 'kubectl delete pods $0 --namespace=$1'
}

kroll() {
    kops rolling-update cluster --force --yes --instance-group master-us-east-1a,master-us-east-1b,master-us-east-1c
}

kpxy() {
    kubectl proxy 2>&1 > /dev/null &
    sleep 1
}

killkpxy() {
    PROXY_PID="$(ps -fC kubectl | grep proxy | cut -d ' ' -f3)"
    kill "$PROXY_PID"
}

kconfig() {
    kubectl config get-contexts
}

upscale_services() {
    cd ~/planet-fitness/
    for deployment_name in identity member-services membership payment-fulfillment hello-world; do
        cd "$deployment_name"
        #kubectl scale --replicas="$(cat deployment.yml | grep replicas | cut -d ' ' -f4)" deployment/"$(cat deployment.yml | grep app: | head -n 1 | cut -d ' ' -f6)"
        kubectl scale --replicas=1 deployment/"$(cat deployment.yml | grep app: | head -n 1 | cut -d ' ' -f6)"
        cd ..
    done
}

upscaleprod() {
    kuseprod
    upscale_services
}

descale_services() {
    #for deployment_name in "$(kubectl get deployments -o json | jq -r '.items[]?.metadata.name?' | tr '\n' ' ')"
    for deployment_name in identity member-services membership payment-fulfillment hello-world
    do
        kubectl scale --replicas=0 deployment/"$deployment_name"
    done
}

descalenonprod() {
    kusenonprod
    descale_services
}

descaleprod() {
    kuseprod
    descale_services
}

unsealsandbox() {
    kusesandbox
    kubectl get pods | grep vault | grep 0/1 | cut -d ' ' -f1
    printf 'Which of the above vault pods do you want to unseal?\n'
    read -r VAULT_POD
    p pf/sandbox/vault_unseal
    kubectl exec -it "$VAULT_POD" -- /bin/sh -c 'vault operator unseal'
}

unsealprod() {
    kuseprod
    kubectl get pods | grep vault | grep 0/1 | cut -d ' ' -f1
    printf 'Which of the above vault pods do you want to unseal?\n'
    read -r VAULT_POD
    p pf/prod/vault_unseal
    kubectl exec -it "$VAULT_POD" -- /bin/sh -c 'vault operator unseal'
}

rekeyprod() {
    kuseprod
    kubectl get pods | grep vault | grep 0/1 | cut -d ' ' -f1
    printf 'Which of the above vault pods do you want to use to rekey?\n'
    read -r VAULT_POD
    p pf/prod/vault_unseal
    kubectl exec -it "$VAULT_POD" -- /bin/sh -c 'vault operator rekey'
}

unsealnonprod() {
    kusenonprod
    kubectl get pods | grep vault | grep 0/1 | cut -d ' ' -f1
    printf 'Which of the above vault pods do you want to unseal?\n'
    read -r VAULT_POD
    p pf/nonprod/vault_unseal
    kubectl exec -it "$VAULT_POD" -- /bin/sh -c 'vault operator unseal'
}

badpods() {
    kubectl get pods --all-namespaces -o json  | jq -r '.items[] | select(.status.phase != "Running" or ([ .status.conditions[] | select(.type == "Ready" and .status == "False") ] | length ) == 1 ) | .metadata.namespace + "/" + .metadata.name'
}

badpodsnonprod() {
    kusenonprod
    badpods
}

badpodsprod() {
    kuseprod
    badpods
}

kuseprod() {
    kubectl config use-context k8.api.planetfitness.com
    pods
}

kusenonprod() {
    kubectl config use-context k8.nonprod.pfx-nonprod.com
    pods
}

kusecdesandbox() {
    kubectl config use-context k8.cde-sandbox.pfx-nonprod.com
    pods
}

kusecdenonprod() {
    kubectl config use-context k8.cde-nonprod.pfx-nonprod.com
    pods
}

kusecdeprod() {
    kubectl config use-context k8.cde.planetfitness.com
    pods
}

kusesandbox() {
    kubectl config use-context k8.sandbox.pfx-nonprod.com
    pods
}

kexec() {
    kubectl exec -it "${1:?'Usage: kexec <pod name>'}" sh
}

current_k8s_context() {
    printf 'Using: %s\n\n' "$(kubectl config get-contexts | grep '*')"
}

hpa() {
    current_k8s_context
    kubectl get hpa
}

nodes() {
    current_k8s_context
    kubectl get nodes -o wide
}

descpods() {
    current_k8s_context
    kubectl describe pods
}

pods() {
    current_k8s_context
    if [ $# -eq 0 ]; then
        kubectl get pods -o wide | grep -v Evicted
    else
        : "${1:?'Usage: pods <column number for sorting>'}"
        kubectl get pods -o wide | sort -k"$1"
    fi
}

podsall() {
    current_k8s_context
    if [ $# -eq 0 ]; then
        kubectl get pods -o wide --all-namespaces | grep -v Evicted
    else
        : "${1:?'Usage: pods <column number for sorting>'}"
        kubectl get pods -o wide --all-namespaces | sort -k"$1"
    fi
}

spods() {
    current_k8s_context
    kubectl get pods -o wide
}

klogs() {
    kubectl logs "$1" | vim -R -c 'set filetype=json' -
}

kflogs() { kubectl logs -f "$@"; }

krollout() {
    current_k8s_context
    kubectl rollout status "${1:?'Usage: krollout <deployment name(i.e. deployment/deployment-name)'}"
}

kscale() {
    printf 'Expects to be running in a directory containing deployment.yml.\n'
    if fexact deployment.yml; then
        kubectl scale --replicas="${1:?'Usage: kscale <replica number>'}" -f deployment.yml
    fi
}

### SSH

newssh() {
    ssh-keygen -t rsa -b 4096 "$@"
}

restartssh() {
    pkill ssh-agent
    eval "$(ssh-agent)"
}

rmallssh() {
    ssh-add -D
    restartssh
}

### GPG

export GPG_TTY="$(tty)"

gpgdir() { dirmngr --daemon --use-tor --homedir /home/rosatolen/.gnupg/;  }

gpgfind() {
    torsocks gpg --verbose --keyserver hkps.pool.sks-keyservers.net --search-key "$1"
}

gpgdec() {
    OUTPUT="${2:?'Missing output file argument. Usage: gpgdec <file_to_decrypt> <output file>'}"
    FILE_TO_DECRYPT="${1:?'Missing file_to_decrypt argument. Usage: gpgdec <file_to_decrypt> <output file>'}"
    gpg --output "$OUTPUT" --decrypt "$FILE_TO_DECRYPT"
}

gpgenc() {
    RECIPIENT="${1:?'Missing recipient argument. Usage: gpgenc <recipient email> <input file> <output file>'}"
    INPUT="${2:?'Missing input file argument. Usage: gpgenc <recipient email> <input file> <output file>'}"
    OUTPUT="${3:?'Missing output file argument. Usage: gpgenc <recipeint email> <input file> <output file>'}"
    gpg  --armor --output "$OUTPUT" --encrypt --recipient "$RECIPIENT" "$INPUT"
}

## HTML

HTMLunescape() {
    python -c 'import html, sys; [print(html.unescape(l), end="") for l in sys.stdin]'
}

## ArchLinux Maintenance
update() {
    curl --silent https://www.archlinux.org/feeds/news/ -w '\n' | HTMLunescape | grep -E '(title>|description>)' > /tmp/archupdate.xml
    vim /tmp/archupdate.xml
    yay
}

maint() {
    printf '\nNOTE!\n This function only works in %s\n' "$HOME"
    # TODO: get # of files and only run if found
    if [ "$(_sudo find ~ -xtype l -print)" ]; then
        printf '\nBroken symlinks found. Printing their status...\n'
        find ~ -xtype l -exec file {} \;
        printf '\nRun dbadlinks to remove them all\n'
    fi

    # TODO: clean this function
    #updates="$(checkupdates)"
    #if [ "$updates" ]; then
    #    echo 'Updates found:'
    #    echo "$updates"
    #fi
}

cleanpackages() {
    echo 'Cleaning all old or uninstalled versions of packages'
    echo 'This disregards possible future downgrades'
    _sudo pacman -Sc
}

dbadlinks() { find ~ -xtype l -delete; }

### Copy-pasting

# Linux specific
#alias c='tr --delete "\n" | xclip -sel clip'
#alias cwn='xclip -sel clip'

# Mac specific
alias c='tr --delete "\n" | pbcopy'

clipfile () {
    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 <file>"
    fi
    xclip -sel clip < "$1"
}

cliptxt () {
    if [ "$#" -eq 0 ]; then
        echo "Usage: $0 <text>"
    fi
    echo "$@" | xclip -sel clip
}

### Password Management

dicecp() {
    ~/.gopaths/diceware/src/github.com/rosatolen/diceware/diceware "$@" | c
}

diceware() {
    ~/.gopaths/diceware/src/github.com/rosatolen/diceware/diceware "$@"
}

### Git

gpr() { p github/rosatolen/ssh; git pull -r; }
gpush() { p github/rosatolen/ssh; git push; }
gstashcachedsavename() { git stash save "$1" --keep-index; }
gc() { git commit -m "$@"; }
gp() { git push origin "$(git branch | grep '*' | cut -d ' ' -f2)"; }

alias gst='git status'
alias gra='git rebase --abort'
alias grc='git rebase --continue'
alias gcan='git commit --amend --no-edit'
alias gcan='git commit --amend --no-edit'

### Ruby

# rbenv
eval "$(rbenv init - bash)"

### Golang

newlocalgo() {
    USAGE='Usage: newlocalgo <project directory> <project owner>'
    PROJ_DIR="${1:?$USAGE}"
    PROJ_OWNER="${2:?$USAGE}"
    if [ -d "$HOME/.gopaths/$PROJ_DIR" ]; then
        printf '\nThere is already a project in the gopath with this name: %s\n' "$HOME/.gopaths/$PROJ_DIR"
    else
        DIR="$HOME/.gopaths/$PROJ_DIR/src/github.com/$PROJ_OWNER/"
        mkdir -p "$DIR"
        printf '\nNavigating into new golang git directory: %s\n' "$DIR"
        if cd "$DIR"; then
            mkdir "$PROJ_DIR"
            cd "$PROJ_DIR"
            printf 'Adding a sample golang .envrc to this directory.\n'
            cp ~/configs/env.example .envrc
            printf 'Edit the .envrc to enable your gopath\n'
            printf 'Add this directory to your ~/.profile if you want a shortcut to return here:\n'
            printf '%s\n' "$PWD"
            printf 'Adding sample Makefile to directory\n'
            cp ~/configs/Makefile.go.example Makefile
            printf '\n NOTE! \n'
            printf 'go.vim binaries are not yet installed. Run vimnewgo to do so.\n\n'
        fi
    fi

}

newgitgo() {
    USAGE='Usage: newgitgo <project directory> <project owner> <git url>'
    PROJ_DIR="${1:?$USAGE}"
    PROJ_OWNER="${2:?$USAGE}"
    GIT_REPO="${3:?$USAGE}"
    if [ -d "$HOME/.gopaths/$PROJ_DIR" ]; then
        printf '\nThere is already a project in the gopath with this name: %s\n' "$HOME/.gopaths/$PROJ_DIR"
    else
        DIR="$HOME/.gopaths/$PROJ_DIR/src/github.com/$PROJ_OWNER/"
        mkdir -p "$DIR"
        printf '\nNavigating into new golang git directory: %s\n' "$DIR"
        if cd "$DIR"; then
            git clone "$GIT_REPO" "$PROJ_DIR"
            cd "$PROJ_DIR"
            printf 'Adding a sample golang .envrc to this directory.\n'
            cp ~/configs/env.example .envrc
            printf 'Add this directory to your ~/.profile if you want a shortcut to return here:\n'
            printf '%s\n' "$PWD"
            printf '\n NOTE! \n'
            printf 'go.vim binaries are not yet installed. Run vimnewgo to do so.\n\n'
        fi
    fi
}

rmgitgo() {
    DIR="${1:?'Usage: rmgitgo <project name>'}"
    PROJ_DIR="$HOME/.gopaths/$DIR"
    if [ -d "$PROJ_DIR" ]; then
        rm -r "$PROJ_DIR"
        printf 'You have removed the golang github project %s\n' "$PROJ_DIR"
    else
        printf 'There is no project with the name %s in the gopath: %s\n"' "$DIR" "$HOME/.gopaths/"
    fi
}

gotestfile() {
    : "${1:?'Usage: gotestfile test_file_name'}"
    cp ~/configs/go_test.sample "$1"
}

alias godice='cd /home/rosatolen/.gopaths/diceware/src/github.com/rosatolen/diceware/'
alias godakez='cd ~/.gopaths/dakezserver/src/github.com/rosatolen/dakezerver/'
alias gokeccak='cd ~/.gopaths/rosatolen/src/github.com/keccak'
alias gospire='cd ~/.gopaths/spire/src/github.com/spiffe/spire'
alias gogumail='cd /home/rosatolen/.gopaths/go-guerilla/src/github.com/flashmob'
alias gomyidp='cd /home/rosatolen/.gopaths/myidp/src/github.com/rosatolen/myidp/'
alias gopass='cd /home/rosatolen/.gopaths/gopass/src/github.com/justwatchcom/gopass'
alias gotalisman='cd /home/rosatolen/.gopaths/talisman/src/github.com/thoughtworks/talisman'
alias gokeybase='cd /home/rosatolen/.gopaths/keybase-cli/src/github.com/keybase/client/'
alias goserve='cd /home/rosatolen/.gopaths/goserve/src/github.com/rosatolen/goserve'
alias gomo='cd /home/rosatolen/.gopaths/gomorena/src/github.com/morena/gomorena/'
alias gofzf='cd /home/rosatolen/.gopaths/fzf/src/github.com/rosatolen/fzf'
alias gopfxtooling='cd /home/rosatolen/.gopaths/pfx-tooling/src/github.com/planetfitness/tooling'
alias gosampleproj='cd /home/rosatolen/.gopaths/sampleproj/src/github.com/rosatolen/sampleproj'

### Rust (not yet installed)

# export PATH="$HOME/.cargo/bin:$PATH"
# . "$HOME"/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/etc/bash_completion.d/cargo
# . "$HOME"/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/etc/bash_completion.d/cargo

### Direnv

da() { direnv allow; }

edirenv() { vim ~/.config/direnv/direnvrc; }

if [ "$SHELL" = "/usr/bin/zsh" ]; then
    eval "$(direnv hook zsh)"
else
    eval "$(direnv hook bash)"
fi

### Java

#export _JAVA_OPTIONS='-Dsun.java2d.opengl=true'

edit_vmoptions(){
    vim ~/.IntelliJIdea2018.1/config/idea64.vmoptions
}

intellij() {
    if archlinux-java status | grep -q 'java-8-openjdk (default)'; then
        bash /opt/intellij-idea-ultimate-edition/bin/idea.sh > /dev/null 2>&1 &
        return
    fi
    printf 'Java 8 is required to run Intellij.\n'
    printf 'To use Java 8, run: $ sudo archlinux-java set java-8-openjdk\n'
}

### Postman

postman() {
    cd ~/Downloads/Postman/ || return 1
    ./Postman &>/dev/null &
    cd -
}
