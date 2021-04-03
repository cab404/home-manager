{ pkgs, config, lib, ... }:
let serviceCfg = config.services.pass-secret-service;
in with lib; {
  options.services.password-store-sync = {
    enable = mkEnableOption "Pass libsecret service";
  };
  config = mkIf serviceCfg.enable {
    assertions = [{
      assertion = config.programs.password-store.enable;
      message = "The 'services.password-store-service' module requires"
        + " 'programs.password-store.enable = true'.";
    }];

    systemd.user.services.pass-secret-service = {
      Unit = { Description = "Pass libsecret service"; };
      Service = {
        # pass-secret-service doesn't use environment variables for some reason.
        ExecStart =
          "${pkgs.pass-secret-service}/bin/pass_secret_service --path $PASSWORD_STORE_DIR";
      };
    };
  };
}
