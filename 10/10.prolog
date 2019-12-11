use_module(library(readutil)).

get_map(Map) :-
  read_file_to_string('input.txt', String, []),
  split_string(String, "\n", "\n", Rows),
  maplist(string_chars, Rows, Grid),
  [Row | _] = Grid,
  length(Row, Width),
  length(Rows, Height),
  Map = [Width, Height, Grid].

map_at(Map, X, Y, Item) :-
  [_Width, _Height, Grid] = Map,
  nth0(Y, Grid, Row),
  nth0(X, Row, Item).

asteroid(Map, X, Y) :- map_at(Map, X, Y, '#').

empty(Map, X, Y) :- map_at(Map, X, Y, '.').

main :-
  get_map(Map),
  [Width, Height, _Grid] = Map,
  Xmax is Width - 1,
  Ymax is Height - 1,
  findall(Count, (
    between(0, Xmax, X),
    between(0, Ymax, Y),
    asteroid(Map, X, Y),
    visible_asteroids(Map, X, Y, Count)
  ), Counts),
  max_list(Counts, MaxCount),
  print(MaxCount),
  nl.

minimize_ray(Ray, MinRay) :-
  [X, Y] = Ray,
  Gcd is max(1, gcd(X, Y)),
  Xmin is X / Gcd,
  Ymin is Y / Gcd,
  MinRay = [Xmin, Ymin].

same_ray(A, B) :-
  minimize_ray(A, Min),
  minimize_ray(B, Min).

all_rays(Width, Height, X, Y, Rays) :-
  Xmin is -X,
  Xmax is Width - X - 1,
  Ymin is -Y,
  Ymax is Height - Y - 1,
  findall([Xray, Yray], (between(Xmin, Xmax, Xray), between(Ymin, Ymax, Yray)), AllRays),
  maplist(minimize_ray, AllRays, MinRays),
  list_to_set(MinRays, Rays).

asteroid_on_ray(Map, X, Y, Ray) :-
  not(Ray = [0,0]),
  [Width, Height, _Grid] = Map,
  [Xray, Yray] = Ray,
  Xa is X + Xray,
  Ya is Y + Yray,
  Xa < Width,
  Ya < Height,
  Xa >= 0,
  Ya >= 0,
  ( asteroid(Map, Xa, Ya)
    -> true
    ; asteroid_on_ray(Map, Xa, Ya, Ray)
  ).

visible_asteroids(Map, X, Y, AsteroidCount) :-
  [Width, Height, _Grid] = Map,
  all_rays(Width, Height, X, Y, Rays),
  length(Rays, RayCount),
  findall(Ray, (member(Ray, Rays), asteroid_on_ray(Map, X, Y, Ray)), AsteroidRays),
  length(AsteroidRays, AsteroidCount).

