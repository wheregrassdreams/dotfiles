{ dotfilesLib, lib, ... }@ctx:
let
  contract = import ../../user/ai/contract.nix { inherit lib; };
in
dotfilesLib.domain ctx (contract // {
  apiOnly = true;
})
