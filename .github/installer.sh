#!/usr/bin/env bash
set -e
cwd=$(pwd)

command -v composer >/dev/null 2>&1 || (echo -e "\033[0;31mERROR: Composer not found!\033[0m Exiting." && exit 1)

printf "\033[0;32mName of your new project?\033[0m "
read project_name

if ! [[ ${project_name} =~ ^[a-z0-9_.-]+$ ]]; then
    echo -e "\033[0;31mERROR: Project name is invalid!\033[0m Exiting." && exit 1
fi

printf "\033[0;32mFull public URL your new project (can be changed later)?\033[0m "
read project_url

if ! [[ ${project_url} =~ ^http ]]; then
    echo -e "\033[0;31mERROR: URL is invalid!\033[0m Exiting." && exit 1
fi

printf "\033[0;32mWhere do you want to create project?\033[0m [DEFAULT: ${cwd}] "
read project_home

if [[ ${project_home} == '' ]]; then
    project_home=${cwd}
fi

printf "\033[0;34mScript will create new project in '${project_home}/${project_name}/', proceed?\033[0m [y/N]"
read proceed

proceed=$(echo "${proceed:0:1}" | awk '{print tolower($0)}')
if [[ ${proceed} != 'y' ]]; then
    echo "Interrupted by user! Exiting." && exit 1
fi

if ! [[ -w "${project_home}" ]]; then
    echo -e "\033[0;31mERROR: Directory ${project_home} is not writable!\033[0m Exiting." && exit 1
fi

mkdir -p "${project_home}/${project_name}/"
cd "${project_home}/${project_name}/"


my_name="bulletproof-wordpress"

dir_languages="languages"
dir_mu_plugins="mu-plugins"
dir_plugins="plugins"
dir_themes="themes"
dir_vendor="vendor"
dir_wordpress="wordpress"

the_mkdir=(
    ${dir_languages}
    ${dir_mu_plugins}
    ${dir_plugins}
    ${dir_themes}
)

composer_config=(
    "sort-packages>true"
    "vendor-dir>${dir_vendor}"
    "repositories.wpackagist>composer>https://wpackagist.org"
    "repositories.wp-languages>composer>https://wp-languages.github.io"
    "extra.dropin-paths.${my_name}/${dir_languages}/>['vendor:koodimonni-language']"
    "extra.dropin-paths.${my_name}/${dir_languages}/${dir_plugins}/>['vendor:koodimonni-plugin-language']"
    "extra.dropin-paths.${my_name}/${dir_languages}/${dir_themes}/>['vendor:koodimonni-theme-language']"
    "extra.installer-paths.${my_name}/${dir_plugins}/{\$name}/>['type:wordpress-plugin']"
    "extra.installer-paths.${my_name}/${dir_themes}/{\$name}/>['type:wordpress-theme']"
    "extra.wordpress-install-dir>${my_name}/${dir_wordpress}/"
)
compoer_requirements=(
    "composer/installers"
    "johnpbloch/wordpress-core"
    "johnpbloch/wordpress-core-installer"
    "mnsami/composer-custom-directory-installer"
    "wpackagist-plugin/stops-core-theme-and-plugin-updates"
)

printf ">>> \033[0;33mInitialize Composer...\033[0m"
composer -q init -n --name "changeme/${project_name}"
printf "\033[0;32m OK!\033[0m\n"


printf ">>> \033[0;33mConfigure Composer...\033[0m"
IFS='>'
for item in "${composer_config[@]}"; do
    read -ra params <<<  "${item}"
    composer -q config ${params[@]}
done

# Workaround https://github.com/composer/composer/issues/2601
sed -i 's#"\['"'"'#["#g' composer.json
sed -i 's#'"'"'\]"#"]#g' composer.json

printf "\033[0;32m OK!\e[0m\n"


printf ">>> \033[0;33mInitialize automation tools...\033[0m"
composer -q create-project -s dev --remove-vcs danie1k/${my_name} ${my_name}
printf "\033[0;32m OK!\e[0m\n"


printf ">>> \033[0;33mInstall Composer requirements...\033[0m"
composer -q require ${compoer_requirements[@]}
printf "\033[0;32m OK!\e[0m\n"


printf ">>> \033[0;33mCreate project files and directories...\033[0m"
curl -s -o .gitignore https://www.gitignore.io/api/composer
printf "\n${my_name}/\n" >> .gitignore
printf '\n!/**/.gitkeep\n' >> .gitignore

for item in "${the_mkdir[@]}"; do
    mkdir -p ${item}
    touch ${item}/.gitkeep
done
printf "\033[0;32m OK!\e[0m\n"


printf ">>> \033[0;33mSet up Ansible files...\033[0m"
curl -s -o ansible.cfg https://raw.githubusercontent.com/danie1k/php-bulletproof-wordpress/dev/ansible/ansible.cfg
curl -s -o ansible.yml https://raw.githubusercontent.com/danie1k/php-bulletproof-wordpress/dev/ansible/ansible.yml
curl -s -o ansible-inventory https://raw.githubusercontent.com/danie1k/php-bulletproof-wordpress/dev/ansible/ansible-inventory

sed -i 's/bpwp-placeholder/'${project_name}'/g' ansible.yml
sed -i 's/bpwp-placeholder/'${project_name}'/g' ansible-inventory
sed -i 's/bpwp-url-placeholder/'${project_url}'/g' ansible.yml

printf '\n/*inventory*\n' >> .gitignore
printf "\033[0;32m OK!\e[0m\n"

printf "\nAll done!\n"
