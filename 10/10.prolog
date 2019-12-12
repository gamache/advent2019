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

set_map_at(Map, X, Y, Item, NewMap) :-
  [Width, Height, Grid] = Map,
  nth0(Y, Grid, Row),
  list_nth0_item_replaced(Row, X, Item, NewRow),
  list_nth0_item_replaced(Grid, Y, NewRow, NewGrid),
  NewMap = [Width, Height, NewGrid].

asteroid(Map, X, Y) :- map_at(Map, X, Y, '#').

empty(Map, X, Y) :- map_at(Map, X, Y, '.').

main :-
  get_map(Map),
  part1(Map, Part1),
  print([part1, Part1]), nl,
  part2(Map, Part1, Part2),
  print([part2, Part2]), nl.

part2(Map, Part1, Part2) :-
  [_Count, [X, Y]] = Part1,
  all_rays(Map, X, Y, Rays),
  sort_rays(Rays, SortedRays),
  shoot_em_up(Map, X, Y, SortedRays, Roids),
  nth1(200, Roids, [RoidX, RoidY]),
  Part2 is RoidX * 100 + RoidY.

shoot_em_up(Map, X, Y, Rays, Roids) :-
  shoot_em_up(Map, X, Y, Rays, [], [], [], Roids).

shoot_em_up(_Map, _X, _Y, _Rays, [], [], Roids, Roids).

shoot_em_up(Map, X, Y, Rays, [], RoidsVapedLately, RoidsVaped, Roids) :-
  reverse(RoidsVapedLately, ReverseRVL),
  append(RoidsVaped, ReverseRVL, NewRoidsVaped),
  shoot_em_up(Map, X, Y, Rays, Rays, [], NewRoidsVaped, Roids).

shoot_em_up(Map, X, Y, Rays, [Ray | Rest], RoidsVapedLately, RoidsVaped, Roids) :-
  ( asteroid_on_ray(Map, X, Y, Ray, Xast, Yast)
    -> NewRVL = [[Xast, Yast] | RoidsVapedLately],
       set_map_at(Map, Xast, Yast, '.', NewMap)
    ; NewRVL = RoidsVapedLately,
      NewMap = Map
  ),
  shoot_em_up(NewMap, X, Y, Rays, Rest, NewRVL, RoidsVaped, Roids).

part1(Map, Part1) :-
  [Width, Height, _Grid] = Map,
  Xmax is Width - 1,
  Ymax is Height - 1,
  findall([X,Y], (between(0, Xmax, X), between(0, Ymax, Y)), Coords),
  findall(Coord, (member(Coord, Coords), [X,Y] = Coord, asteroid(Map, X, Y)), RoidCoords),
  findall([Count, [X, Y]], (member([X,Y], RoidCoords), visible_asteroids(Map, X, Y, Count)), CountCoords),
  sort(1, @>, CountCoords, SortedCountCoords),
  [Part1 | _] = SortedCountCoords.

minimize_ray(Ray, MinRay) :-
  [X, Y] = Ray,
  Gcd is max(1, gcd(X, Y)),
  Xmin is X / Gcd,
  Ymin is Y / Gcd,
  MinRay = [Xmin, Ymin].

same_ray(A, B) :-
  minimize_ray(A, Min),
  minimize_ray(B, Min).

all_rays([Width, Height, _Grid], X, Y, Rays) :-
  all_rays(Width, Height, X, Y, Rays).

all_rays(Width, Height, X, Y, Rays) :-
  Xmin is -X,
  Xmax is Width - X - 1,
  Ymin is -Y,
  Ymax is Height - Y - 1,
  findall([Xray, Yray], (between(Xmin, Xmax, Xray), between(Ymin, Ymax, Yray)), AllRays),
  maplist(minimize_ray, AllRays, MinRays),
  list_to_set(MinRays, Rays).

asteroid_on_ray(Map, X, Y, Ray, Xast, Yast) :-
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
    -> Xast = Xa, Yast = Ya
    ; asteroid_on_ray(Map, Xa, Ya, Ray, Xast, Yast)
  ).

visible_asteroids(Map, X, Y, AsteroidCount) :-
  [Width, Height, _Grid] = Map,
  all_rays(Width, Height, X, Y, Rays),
  findall(Ray, (member(Ray, Rays), asteroid_on_ray(Map, X, Y, Ray, _, _)), AsteroidRays),
  length(AsteroidRays, AsteroidCount).

%% part 2

ray_angle([X, Y], Radians) :- X = 0, Y > 0, !, Radians is pi / 2.
ray_angle([X, _], Radians) :- X = 0, Radians is 3 * pi / 2.
ray_angle([X, Y], Radians) :- X > 0, Y < 0, !, Radians is 2 * pi + atan(Y / X).
ray_angle([X, Y], Radians) :- X > 0, Radians is atan(Y / X).
ray_angle([X, Y], Radians) :- X < 0, Radians is pi + atan(Y / X).

clockwise_angle([X, Y], ClockwiseRadians) :-
  ray_angle([X, Y], Radians),
  Angle is Radians - (3 * pi / 2),
  (Angle < 0 -> ClockwiseRadians is Angle + 2 * pi ; ClockwiseRadians is Angle).

pairs([], [], []).
pairs([A|As], [B|Bs], [[A,B]|Pairs]) :- pairs(As, Bs, Pairs).

sort_rays(Rays, SortedRays) :-
  maplist(clockwise_angle, Rays, Angles),
  pairs(Angles, Rays, AngleRays),
  sort(1, @<, AngleRays, SortedAngleRays),
  pairs(_SortedAngles, SortedRays, SortedAngleRays).

% I got this from Stack Overflow
list_nth0_item_replaced(Es, N, X, Xs) :-
  same_length(Es, Xs),
  append(Prefix, [_|Suffix], Es),
  length(Prefix, N),
  append(Prefix, [X|Suffix], Xs).


