{ isDarwin, isWsl, ... }: {
  modules = {
    aerospace.enable = isDarwin;
    astronvim.enable = true;
    browser.enable = !isWsl;
    cli.core.enable = true;
    cli.desktop.enable = true;
    cli.tools.enable = true;
    dev.enable = true;
    fish.enable = true;
    freecad.enable = true;
    ghostty.enable = !isWsl;
    git.enable = true;
    gui.enable = !(isDarwin || isWsl);
    kitty.enable = true;
    lazyvim.enable = true;
    # lsd.enable = true;
    # mpv.enable = !isWsl;
    # neovide.enable = true;
    shell.enable = true;
    ssh.enable = true;
    # vscode.enable = true;
    wayland.enable = !(isDarwin || isWsl);
    # wezterm.enable = !isDarwin;
    xdg.enable = !isDarwin;
    # zellij.enable = true;
    zsh.enable = true;

  };
}
