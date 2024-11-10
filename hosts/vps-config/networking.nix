{lib, ...}: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [
      "8.8.8.8"
    ];
    defaultGateway = "89.110.119.1";
    defaultGateway6 = {
      address = "";
      interface = "ens3";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce true;
    interfaces = {
      ens3 = {
        ipv4.addresses = [
          {
            address = "89.110.119.238";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = "fe80::5054:ff:fe01:d838";
            prefixLength = 64;
          }
        ];
        ipv4.routes = [
          {
            address = "89.110.119.1";
            prefixLength = 32;
          }
        ];
        ipv6.routes = [
          {
            address = "";
            prefixLength = 128;
          }
        ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="52:54:00:01:d8:38", NAME="ens3"

  '';
}
