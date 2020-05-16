#!/usr/bin/env bash
set -e

ansible_dir="ansible"

git_url="https://raw.githubusercontent.com/danie1k/php-bulletproof-wordpress"
git_branch="dev"

cwd=$(pwd)

function _die() { echo -e "\033[0;31mERROR: $1\033[0m Exiting." && exit 1; }
function _info() { printf ">>> \033[0;33m$1\033[0m"; }
function _ok() { printf "\033[0;32m OK!\e[0m\n"; }
function _q() { printf "\033[0;32m$1\033[0m "; }

function _welcome() {
    echo -e "\033[0;32m                         ╭────────────────────╮"
    echo -e "╭────────────────────────┤\033[0m  Welcome to BPWP!  \033[0;32m├────────────────────────╮"
    echo -e "│                        ╰────────────────────╯                        │"
    echo -e "│\033[0m This tool will automatically create for you basic project structure. \033[0;32m│"
    echo -e "│\033[0m This includes:                                                       \033[0;32m│"
    echo -e "│\033[0m  • Full directories structure in given location                      \033[0;32m│"
    echo -e "│\033[0m  • Ansible playbook files                                            \033[0;32m│"
    echo -e "│\033[0m  • Initial Composer Project configuration                            \033[0;32m│"
    echo -e "│\033[0m  • Installation of danie1k/bulletproof-wordpress inside your project \033[0;32m│"
    echo -e "╰──────────────────────────────────────────────────────────────────────╯\033[0m"
    printf "Press Enter to continue..." && read && echo;
}

function _check_requirements() {
    _info "Checking system requirements..."
    local required_commands=(ansible-playbook composer grep sed)
    local missing_commands=""

    for cmdname in ${required_commands[@]}; do command -v "${cmdname}" >/dev/null 2>&1 || missing_commands+=" ${cmdname}"; done

    if ! [[ -z "${missing_commands}" ]]; then
        echo  && _die "Following commands were not found: ${missing_commands}"
    else
        _ok
    fi
}

function _download_configuration() {
    _info "Downloading directories configuration..."
    local url="${git_url}/${git_branch}/ansible/roles/bulletproof-wordpress/vars/bpwp-dir.yml"
    yaml=$(curl -s "${url}")

    IFS=$'\n'
    for yaml_item in ${yaml[@]}; do
        if ! ($( echo "${yaml_item}" | grep -Eq '^[a-z_]+:\s[a-z0-9_-]+' )); then
            echo -e "\033[0;31mERROR: Unable to load bpwp-dir.yml!\033[0m Exiting." && exit 1
        fi
        eval $(echo "export ${yaml_item}\"" | sed -E 's/:\s+/="/')
    done
    _ok
}

function _create_project_directories() {
    _info "Creating project directories..."

    mkdir -p "${project_home}/${project_name}/"
    cd "${project_home}/${project_name}/"

    local the_mkdir=(
        "${bpwp_dir_languages}"
        "${bpwp_dir_mu_plugins}"
        "${bpwp_dir_plugins}"
        "${bpwp_dir_themes}"
    )
    for item in "${the_mkdir[@]}"; do
        mkdir -p "${item}"
        touch "${item}/.gitkeep"
    done

    _ok
}

function _create_gitignore() {
    _info "Creating .gitignore file..."

    printf "# danie1k/${bpwp_my_name}\n\n" > .gitignore

    printf "${ansible_dir}/inventory\n" >> .gitignore
    printf "${ansible_dir}/vars.yml\n\n" >> .gitignore

    printf "${bpwp_my_name}/*\n\n" >> .gitignore

    curl -s https://www.gitignore.io/api/composer >> .gitignore

    printf '\n\n!/**/.gitkeep\n' >> .gitignore

    _ok
}

function _initialize_composer() {
    _info "Initializing Project Composer..."
    composer -q init -n --name "changeme/${project_name}"
    _ok
}

function _configure_composer() {
    _info "Configuring Project Composer..."

    local composer_config=(
        "sort-packages>true"
        "vendor-dir>${bpwp_dir_vendor}"
        "repositories.wpackagist>composer>https://wpackagist.org"
        "repositories.wp-languages>composer>https://wp-languages.github.io"
        "extra.dropin-paths.${bpwp_my_name}/${bpwp_dir_languages}/>['vendor:koodimonni-language']"
        "extra.dropin-paths.${bpwp_my_name}/${bpwp_dir_languages}/${bpwp_dir_plugins}/>['vendor:koodimonni-plugin-language']"
        "extra.dropin-paths.${bpwp_my_name}/${bpwp_dir_languages}/${bpwp_dir_themes}/>['vendor:koodimonni-theme-language']"
        "extra.installer-paths.${bpwp_my_name}/${bpwp_dir_plugins}/{\$name}/>['type:wordpress-plugin']"
        "extra.installer-paths.${bpwp_my_name}/${bpwp_dir_themes}/{\$name}/>['type:wordpress-theme']"
        "extra.wordpress-install-dir>${bpwp_my_name}/${bpwp_dir_wordpress}/"
    )

    IFS='>'
    for item in "${composer_config[@]}"; do
        read -ra params <<<  "${item}"
        composer -q config ${params[@]}
    done

    # Workaround https://github.com/composer/composer/issues/2601
    sed -i 's#"\['"'"'#["#g' composer.json
    sed -i 's#'"'"'\]"#"]#g' composer.json

    _ok
}

function _initialize_bpwp() {
    _info "Initializing danie1k/${bpwp_my_name}..."
    composer -q create-project -s dev --remove-vcs danie1k/${bpwp_my_name} ${bpwp_my_name}
    _ok
}

function _install_composer_requirements() {
    _info "Installing Composer requirements..."

    local compoer_requirements=(
        "composer/installers"
        "johnpbloch/wordpress-core"
        "johnpbloch/wordpress-core-installer"
        "mnsami/composer-custom-directory-installer"
    )
    composer -q require ${compoer_requirements[@]}
    _ok
}

function _configure_ansible() {
    _info "Configuring Ansible..."

    local file_list=(
        "ansible.cfg"
        "ansible.yml"
        "inventory"
        "vars.yml"
    )
    mkdir ${ansible_dir}
    for item in "${file_list[@]}"; do
        curl -s -o "${ansible_dir}/${item}" "${git_url}/${git_branch}/ansible/${item}"
        sed -i 's/bpwp-placeholder/'${project_name}'/g' "${ansible_dir}/${item}"
    done

    _ok
}


_welcome

_q "Name of your project?" && read project_name
[[ "${project_name}" =~ ^[a-z0-9_-]+$ ]] || _die "Project name is invalid!"

_q "Project files location? [DEFAULT: ${cwd}]" && read project_home
[[ -z "${project_home}" ]] && project_home="${cwd}" || project_home="${project_home%/}"
[[ -d "${project_home}" ]] && [[ -w "${project_home}" ]] || _die "Given directory is invalid or not writable!"

_q "Script will create new project in '${project_home}/${project_name}/', proceed? [y/N]" && read proceed
[[ "${proceed:0:1}" == 'y' ]] || [[ "${proceed:0:1}" == 'Y' ]] || _die "Interrupted by user."

_check_requirements
_download_configuration
_create_project_directories
_create_gitignore
_initialize_composer
_configure_composer
_initialize_bpwp
_install_composer_requirements
_configure_ansible

echo -e "\n\033[0;32m╭──────────────────────────────────────────────────────────────────────╮"
echo -e "│\033[0m                      Congratulations, all done!                      \033[0;32m│"
echo -e "╰──────────────────────────────────────────────────────────────────────╯\033[0m\n"
echo -e "Your Project files has been created in:\n${project_home}/${project_name}/\n"
