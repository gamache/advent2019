:- use_module(library(readutil)).
:- use_module(library(dcg/basics)).

get_positions(Positions) :-
  read_file_to_string('input.txt', String, []),
  split_string(String, "\n", "\n", Lines),
  maplist(position, Lines, Positions).

position(Line, Position) :-
  atom_codes(Line, Codes),
  phrase(position(Position), Codes, []).

new_moon(Position, [Position, [0,0,0]]).

main :-
  get_positions(Positions),
  maplist(new_moon, Positions, Moons),
  iter_n(Moons, 1000, OutMoons),
  total_kinetic_energy(OutMoons, E),
  print(E), nl.

% <x=9, y=-8, z=-3>
position([X, Y, Z]) --> "<", xvalue(X), ", ", yvalue(Y), ", ", zvalue(Z), ">".
xvalue(X) --> "x=", integer(X).
yvalue(Y) --> "y=", integer(Y).
zvalue(Z) --> "z=", integer(Z).

iter_once(Moons, IterMoons) :-
  gravitize_moons(Moons, GravMoons),
  maplist(apply_velocity, GravMoons, IterMoons).

iter_n(Moons, 0, Moons).

iter_n(Moons, N, IterMoons) :-
  iter_once(Moons, NewMoons),
  N1 is N - 1,
  iter_n(NewMoons, N1, IterMoons).

total_kinetic_energy(Moons, Energy) :-
  maplist(kinetic_energy, Moons, Energies),
  sum_list(Energies, Energy).

kinetic_energy([[X, Y, Z],[Dx, Dy, Dz]], Energy) :-
  PositionEnergy is abs(X) + abs(Y) + abs(Z),
  VelocityEnergy is abs(Dx) + abs(Dy) + abs(Dz),
  Energy is PositionEnergy * VelocityEnergy.

apply_gravity(M1, M2, G1, G2) :-
  [[M1x, M1y, M1z],[V1x, V1y, V1z]] = M1,
  [[M2x, M2y, M2z],[V2x, V2y, V2z]] = M2,
  dv(M1x, M2x, Dx),
  dv(M1y, M2y, Dy),
  dv(M1z, M2z, Dz),
  G1x is V1x + Dx, G2x is V2x - Dx,
  G1y is V1y + Dy, G2y is V2y - Dy,
  G1z is V1z + Dz, G2z is V2z - Dz,
  G1 = [[M1x, M1y, M1z], [G1x, G1y, G1z]],
  G2 = [[M2x, M2y, M2z], [G2x, G2y, G2z]].

dv(A, B, D) :- A < B, D is 1.
dv(A, B, D) :- A > B, D is -1.
dv(A, A, 0).

apply_velocity(M, V) :-
  [[X, Y, Z], [Dx, Dy, Dz]] = M,
  X2 is X + Dx,
  Y2 is Y + Dy,
  Z2 is Z + Dz,
  V = [[X2, Y2, Z2], [Dx, Dy, Dz]].

gravitize_moons(Moons, GravMoons) :-
  gravitize_moons(Moons, [], GravMoons).

gravitize_moons([], GravMoons, GravMoons).

gravitize_moons([Moon | Rest], MoonsAcc, GravMoons) :-
  attract_moon_to_moons(Moon, Rest, [], NewMoon, NewRest),
  gravitize_moons(NewRest, [NewMoon | MoonsAcc], GravMoons).

attract_moon_to_moons(NewMoon, [], NewRest, NewMoon, NewRest).

attract_moon_to_moons(A, [B | Rest], RestAcc, NewMoon, NewRest) :-
  apply_gravity(A, B, NewA, NewB),
  attract_moon_to_moons(NewA, Rest, [NewB | RestAcc], NewMoon, NewRest).


