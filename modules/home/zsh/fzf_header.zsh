fzf_header() {
  local color1='\033[38;2;103;103;103m'
  local reset='\033[0m'
  echo -n "${color1}^/${reset} toggle preview  ${color1}^D${reset}/${color1}^U${reset} scroll preview  ${color1}TAB${reset} select multi"
}

export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header \"$(fzf_header)\" --info-command='printf \$FZF_MATCH_COUNT/\$FZF_TOTAL_COUNT' "
