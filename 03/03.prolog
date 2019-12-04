use_module(library(readutil)).

get_directions(A, B) :-
  read_file_to_string('input.txt', String, []),
  split_string(String, "\n", "\n", Lines),
  [Astr, Bstr] = Lines,
  split_string(Astr, ",", ",", Astrs),
  split_string(Bstr, ",", ",", Bstrs),
  maplist(string_direction, Astrs, A),
  maplist(string_direction, Bstrs, B).

string_direction(String, Direction) :-
  string_chars(String, Chars),
  [AimChar | LenChars] = Chars,
  string_chars(LenStr, LenChars),
  number_string(Len, LenStr),
  Direction = [AimChar, Len].

main :-
  get_directions(A, B),
  manhattan_closest_intersection(A, B, Distance),
  print(Distance), nl.


manhattan_closest_intersection(A, B, Distance) :-
  points_on_path(A, Apoints),
  print(Apoints), nl,
  points_on_path(B, Bpoints),
  print(Bpoints), nl,
  intersection(Apoints, Bpoints, Intersections),
  print(Interserctions), nl,
  maplist(intersection_distance, Intersections, Distances),
  print(Distances), nl,
  subtract(Distances, [0], NonzeroDistances),
  listmin(NonzeroDistances, Distance).


intersection_distance([X, Y], Distance) :-
  Distance is abs(X) + abs(Y).


points_on_path(Directions, Points) :-
  points_on_path(Directions, 0, 0, [], Points).

points_on_path([], _X, _Y, Acc, Points) :-
  Points = Acc.

points_on_path([Direction | Rest], X, Y, Acc, Points) :-
  points(Direction, X, Y, [], NewPoints, NewX, NewY),
  append(Acc, NewPoints, NewAcc),
  points_on_path(Rest, NewX, NewY, NewAcc, Points).


points([_, 0], X, Y, Acc, NewPoints, NewX, NewY) :-
  NewX = X,
  NewY = Y,
  NewPoints = Acc.

points(['U', Len], X, Y, Acc, NewPoints, NewX, NewY) :-
  NewLen is Len - 1,
  Yy is Y + 1,
  NewAcc = [[X,Y] | Acc],
  points(['U', NewLen], X, Yy, NewAcc, NewPoints, NewX, NewY).

points(['D', Len], X, Y, Acc, NewPoints, NewX, NewY) :-
  NewLen is Len - 1,
  Yy is Y - 1,
  NewAcc = [[X,Y] | Acc],
  points(['D', NewLen], X, Yy, NewAcc, NewPoints, NewX, NewY).

points(['L', Len], X, Y, Acc, NewPoints, NewX, NewY) :-
  NewLen is Len - 1,
  Xx is X - 1,
  NewAcc = [[X,Y] | Acc],
  points(['L', NewLen], Xx, Y, NewAcc, NewPoints, NewX, NewY).

points(['R', Len], X, Y, Acc, NewPoints, NewX, NewY) :-
  NewLen is Len - 1,
  Xx is X + 1,
  NewAcc = [[X,Y] | Acc],
  points(['R', NewLen], Xx, Y, NewAcc, NewPoints, NewX, NewY).


listmin([First | Rest], Min) :-
  listmin(Rest, First, Min).

listmin([], Acc, Min) :-
  Min = Acc.

listmin([First | Rest], Acc, Min) :-
  NewAcc is min(First, Acc),
  listmin(Rest, NewAcc, Min).

