{ userName, inputs, ... }: {
  imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];
  nix-homebrew = {
    enable = true;
    user = userName;
    enableRosetta = false;
    mutableTaps = true;
    taps = {};
  };
  environment.systemPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];
}
