{ hostname, ... }:
{
  imports = [
    ./${hostname}
    ./internationalisation
  ];


}
