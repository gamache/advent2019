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
  points_on_path(A, Apoints, Asteps),
  points_on_path(B, Bpoints, Bsteps),
  intersection(Apoints, Bpoints, Intersections),
  subtract(Intersections, [[0,0]], RealIntersections),

  %% manhattan
  maplist(intersection_distance, RealIntersections, Distances),
  listmin(Distances, Distance),
  print(Distance), nl,

  %% steps
  intersections_steps(RealIntersections, Apoints, Asteps, Bpoints, Bsteps, [], Steps),
  listmin(Steps, Steps),
  print(Steps), nl.


intersection_distance([X, Y], Distance) :-
  Distance is abs(X) + abs(Y).


intersections_steps([], _Asteps, _Apoints, _Bsteps, _Bpoints, StepsAcc, Steps) :-
  Steps = StepsAcc.

intersections_steps([Intersection | Rest], Apoints, Asteps, Bpoints, Bsteps, StepsAcc, Steps) :-
  nth0(Aindex, Apoints, Intersection),
  nth0(Bindex, Bpoints, Intersection),
  nth0(Aindex, Asteps, Astep),
  nth0(Bindex, Bsteps, Bstep),
  Step is Astep + Bstep,
  print(Step), nl,
  intersections_steps(Rest, Apoints, Asteps, Bpoints, Bsteps, [Step | StepsAcc], Steps).


points_on_path(Directions, Points, Steps) :-
  points_on_path(Directions, 0, 0, 0, [], [], Points, Steps).

points_on_path([], _X, _Y, _StepCount, PointsAcc, StepsAcc, Points, Steps) :-
  reverse(StepsAcc, RevStepsAcc),
  reverse(PointsAcc, RevPointsAcc),
  Steps = RevStepsAcc,
  Points = RevPointsAcc.

points_on_path([Direction | Rest], X, Y, StepCount, PointsAcc, StepsAcc, Points, Steps) :-
  points(Direction, X, Y, StepCount, [], [], NewPoints, NewSteps, NewX, NewY, NewStepCount),
  append(NewPoints, PointsAcc, NewPointsAcc),
  append(NewSteps, StepsAcc, NewStepsAcc),
  points_on_path(Rest, NewX, NewY, NewStepCount, NewPointsAcc, NewStepsAcc, Points, Steps).


points([_, 0], X, Y, StepCount, PointsAcc, StepsAcc, Points, Steps, EndingX, EndingY, EndingSteps) :-
  Points = PointsAcc,
  Steps = StepsAcc,
  EndingX = X,
  EndingY = Y,
  EndingSteps = StepCount.

points(['U', Len], X, Y, StepCount, PointsAcc, StepsAcc, Points, Steps, EndingX, EndingY, EndingSteps) :-
  NewLen is Len - 1,
  NewY is Y + 1,
  NewStepCount is StepCount + 1,
  NewPointsAcc = [[X,Y] | PointsAcc],
  NewStepsAcc = [StepCount | StepsAcc],
  points(['U', NewLen], X, NewY, NewStepCount, NewPointsAcc, NewStepsAcc,
    Points, Steps, EndingX, EndingY, EndingSteps).

points(['D', Len], X, Y, StepCount, PointsAcc, StepsAcc, Points, Steps, EndingX, EndingY, EndingSteps) :-
  NewLen is Len - 1,
  NewY is Y - 1,
  NewStepCount is StepCount + 1,
  NewPointsAcc = [[X,Y] | PointsAcc],
  NewStepsAcc = [StepCount | StepsAcc],
  points(['D', NewLen], X, NewY, NewStepCount, NewPointsAcc, NewStepsAcc,
    Points, Steps, EndingX, EndingY, EndingSteps).

points(['R', Len], X, Y, StepCount, PointsAcc, StepsAcc, Points, Steps, EndingX, EndingY, EndingSteps) :-
  NewLen is Len - 1,
  NewX is X + 1,
  NewStepCount is StepCount + 1,
  NewPointsAcc = [[X,Y] | PointsAcc],
  NewStepsAcc = [StepCount | StepsAcc],
  points(['R', NewLen], NewX, Y, NewStepCount, NewPointsAcc, NewStepsAcc,
    Points, Steps, EndingX, EndingY, EndingSteps).

points(['L', Len], X, Y, StepCount, PointsAcc, StepsAcc, Points, Steps, EndingX, EndingY, EndingSteps) :-
  NewLen is Len - 1,
  NewX is X - 1,
  NewStepCount is StepCount + 1,
  NewPointsAcc = [[X,Y] | PointsAcc],
  NewStepsAcc = [StepCount | StepsAcc],
  points(['L', NewLen], NewX, Y, NewStepCount, NewPointsAcc, NewStepsAcc,
    Points, Steps, EndingX, EndingY, EndingSteps).


listmin([First | Rest], Min) :-
  listmin(Rest, First, Min).

listmin([], Acc, Min) :-
  Min = Acc.

listmin([First | Rest], Acc, Min) :-
  NewAcc is min(First, Acc),
  listmin(Rest, NewAcc, Min).

