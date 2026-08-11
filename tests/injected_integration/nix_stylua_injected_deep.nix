{ pkgs }:
let
  y = "hello";
in
# lua
''
  local deep={a={b={c={d={e=1}}}}}
  local function f(x)if x then return{ok=true,val=x} end end
  local msg = "a:${y}:b:${y}"
  local json = [[${
    builtins.toJSON {
      a = 1;
      b = {
        c = 2;
      };
      list = [
        1
        2
        3
      ];
    }
  }]]
  local out=f(deep.a.b.c.d.e)
  if out then out.val=out.val+1 end
''
