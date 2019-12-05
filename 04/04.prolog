use_module(library(readutil)).

get_input_range(Min, Max) :-
  read_file_to_string('input.txt', String, []),
  split_string(String, "\n", "\n", [Line1 | _]),
  split_string(Line1, "-", "-", Strs),
  [MinStr, MaxStr] = Strs,
  number_string(Min, MinStr),
  number_string(Max, MaxStr).

main :-
  get_input_range(Min, Max),

  findall(Password, part1_password(Password, Min, Max), Pwlist1),
  list_to_set(Pwlist1, Passwords1),
  length(Passwords1, Len1),
  print(Len1), nl,

  findall(Password, part2_password(Password, Min, Max), Pwlist2),
  list_to_set(Pwlist2, Passwords2),
  length(Passwords2, Len2),
  print(Len2), nl.

password(Password, Min, Max) :-
  [A, B, C, D, E, F] = Password,
  between(0, 9, A),
  between(0, 9, B),
  between(0, 9, C),
  between(0, 9, D),
  between(0, 9, E),
  between(0, 9, F),
  A >= B,
  B >= C,
  C >= D,
  D >= E,
  E >= F,
  password_number(Password, Number),
  Number >= Min,
  Number =< Max.

part1_password(Password, Min, Max) :-
  password(Password, Min, Max),
  has_double(Password).

part2_password(Password, Min, Max) :-
  password(Password, Min, Max),
  has_standalone_double(Password).

has_double([X, X, _, _, _, _]).
has_double([_, X, X, _, _, _]).
has_double([_, _, X, X, _, _]).
has_double([_, _, _, X, X, _]).
has_double([_, _, _, _, X, X]).

has_standalone_double([X, X, A, _, _, _]) :- not(X = A).
has_standalone_double([A, X, X, B, _, _]) :- not(X = A), not(X = B).
has_standalone_double([_, A, X, X, B, _]) :- not(X = A), not(X = B).
has_standalone_double([_, _, A, X, X, B]) :- not(X = A), not(X = B).
has_standalone_double([_, _, _, A, X, X]) :- not(X = A).

password_number([A, B, C, D, E, F], Number) :-
  Number is A*100000 + B*10000 + C*1000 + D*100 + E*10 + F.
