{ pkgs, ... }: {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    keymap.mgr.prepend_keymap = [
      { on = [ "<C-/>" "<C-->" ]; run = "plugin toggle-pane min-preview"; desc = "Show or hide the preview pane"; }
      { on = [ "<C-/>" "<C-->" ]; run = "plugin toggle-pane max-preview"; desc = "Maximize or restore the preview pane"; }
      { on = [ "<C-d>" ]; run = "seek 5"; desc = "Preview page down"; }
      { on = [ "<C-u>" ]; run = "seek -5"; desc = "Preview page up"; }
    ];
    settings = {
      mgr = { show_hidden = false; sort_by = "mtime"; sort_dir_first = true; sort_reverse = true; ratio = [ 1 3 6 ]; };
      preview = { max_width = 2000; max_height = 1200; };
      plugin = {
        prepend_previewers = [
          { name = "*.csv"; run = "duckdb"; }
          { name = "*.tsv"; run = "duckdb"; }
          # { name = "*.json"; run = "duckdb"; }
          { name = "*.parquet"; run = "duckdb"; }
          # { name = "*.txt"; run = "duckdb"; }
          { name = "*.xlsx"; run = "duckdb"; }
          { name = "*.db"; run = "duckdb"; }
          { name = "*.duckdb"; run = "duckdb"; }
        ];
        prepend_preloaders = [
          { name = "*.csv"; run = "duckdb"; multi = false; }
          { name = "*.tsv"; run = "duckdb"; multi = false; }
          # { name = "*.json"; run = "duckdb"; multi = false; }
          { name = "*.parquet"; run = "duckdb"; multi = false; }
          # { name = "*.txt"; run = "duckdb"; multi = false; }
          { name = "*.xlsx"; run = "duckdb"; multi = false; }
        ];
      };
    };
  };
  home.packages = [ pkgs.duckdb ];
}
