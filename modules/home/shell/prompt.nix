{ ... }: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = ''
        $directory''${custom.git_branch_tail}
        $character
      '';

      directory = {
        style = "white";
        truncation_length = 3;
        format = "[$path]($style) ";
      };

      custom.git_branch_tail = {
        command = "git rev-parse --abbrev-ref HEAD | awk -F/ '{print $NF}'";
        when = "git rev-parse --is-inside-work-tree 2>/dev/null";
        symbol = " ";
        format = "[$symbol$output](dimmed) ";
      };

      character = {
        success_symbol = "[➜](green)";
        error_symbol = "[➜](red)";
        vicmd_symbol = "[➜](yellow)";
      };

      python = {
        symbol = " ";
        style = "yellow";
        version_format = "v\${raw}";
        format = "[$symbol]($style)[$version](dimmed) ";
      };

      golang = {
        symbol = " ";
        style = "cyan";
        format = "[$symbol$version](dimmed) ";
      };

      nodejs = {
        symbol = " ";
        style = "green";
        format = "[$symbol]($style)[$version](dimmed) ";
      };

      rust = {
        symbol = " ";
        style = "red";
        format = "[$symbol$version](dimmed) ";
      };
    };
  };
}
