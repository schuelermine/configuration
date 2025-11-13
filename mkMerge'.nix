lib: modules:
let
  op =
    { imports, modules }:
    module:
    if module ? imports then
      {
        imports = imports ++ module.imports;
        modules = modules ++ [ (builtins.removeAttrs module [ "imports" ]) ];
      }
    else
      {
        inherit imports;
        modules = modules ++ [ module ];
      };
  res = builtins.foldl' op {
    imports = [ ];
    modules = [ ];
  } modules;
in
{
  imports = res.imports;
  config = lib.mkMerge res.modules;
}
