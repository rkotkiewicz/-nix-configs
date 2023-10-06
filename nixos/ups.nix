{ inputs, lib, config, pkgs, ... }:
let
  vid = "0463";
  pid = "FFFF";
  password = "TODO";
in {

#    services.prometheus.exporters.nut.enable=true;

  power.ups = {
    enable = true;
    mode = "standalone";
    ups.eaton = {
      # find your driver here:
      # https://networkupstools.org/docs/man/usbhid-ups.html
      driver = "usbhid-ups";
      description = "Eaton ups";
      port = "auto";
      directives = [
        "vendorid = ${vid}"
        "productid = ${pid}"
      ];
      # this option is not valid for usbhid-ups
      maxStartDelay = null;
    };
    maxStartDelay = 10;
  };


  users = {
    users.nut = {
      isSystemUser = true;
      group = "nut";
      # it does not seem to do anything with this directory
      # but something errored without it, so whatever
      home = "/var/lib/nut";
      createHome = true;
    };
    groups.nut = { };
  };
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="${vid}", ATTRS{idProduct}=="${pid}", MODE="0664", GROU="nut"
  '';

  systemd.services.upsd.serviceConfig = {
    User = "root";
    Group = "nut";
  };

  systemd.services.upsdrv.serviceConfig = {
    User = "root";
    Group = "nut";
  };

  # reference: https://github.com/networkupstools/nut/tree/master/conf
  environment.etc = {
    # all this file needs to do is exist
    upsdConf = {
      text = "";
      target = "nut/upsd.conf";
      mode = "0440";
      group = "nut";
      user = "nut";
    };
    upsdUsers = {
      # update upsmonConf MONITOR to match
      text = ''
      [upsmon]
        password = ${password}
        upsmon master
      '';
      target = "nut/upsd.users";
      mode = "0440";
      group = "nut";
      user = "nut";
    };
#        MINSUPPLIES 1
#        SHUTDOWNCMD "shutdown -h 0"
#        POLLFREQ 5
#        POLLFREQALERT 5
#        HOSTSYNC 15
#        DEADTIME 15
#        RBWARNTIME 43200
#        NOCOMMWARNTIME 300
#        FINALDELAY 5
#        MONITOR cyberpower@localhost 1 upsmon ${password} master
    upsmonConf = {
      text = ''
        RUN_AS_USER nut

        MONITOR eaton@localhost 1 upsmon ${password} master
      '';
      target = "nut/upsmon.conf";
      mode = "0444";
    };
  };
}