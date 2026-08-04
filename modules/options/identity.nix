{ lib, ... }:
{
  options.my.identity = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "Account name supplied by the composition host.";
    };
    fullname = lib.mkOption {
      type = lib.types.str;
      description = "Personal display name supplied by the composition host.";
    };
    email = lib.mkOption {
      type = lib.types.str;
      description = "Personal email address supplied by the composition host.";
    };
  };
}
