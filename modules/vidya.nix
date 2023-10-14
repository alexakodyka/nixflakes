{ pkgs, user, ... }:
{
  
  # Required to run Windows applications ie World of Warcraft
  users.users.${user} = {
  packages = with pkgs; [ 
      (wineWowPackages.full.override {
        wineRelease = "staging";
        mingwSupport = true;
       })
      winetricks
    ];
  };

  # This can optionally be installed via flatpack. 
  # YMMV - not many supported games
  programs = {
    steam.enable = true;  
  };
}
