use_module(library(readutil)).

get_input_numbers(Numbers) :-
  read_file_to_string('input.txt', String, []),
  split_string(String, "\n", "\n", Strings),
  maplist(number_string, Numbers, Strings).

main :-
  get_input_numbers(Masses),
  masses_to_fuel(Masses, Fuel),
  print(Fuel), nl,
  masses_to_total_fuel(Masses, TotalFuel),
  print(TotalFuel), nl.

masses_to_fuel(Masses, Fuel) :-
  maplist(mass_to_fuel, Masses, Fuels),
  sumlist(Fuels, Fuel).

mass_to_fuel(Mass, Fuel) :-
  D3 = div(Mass, 3),
  Fuel = D3 - 2.

masses_to_total_fuel(Masses, Fuel) :-
  maplist(mass_to_total_fuel, Masses, Fuels),
  sumlist(Fuels, Fuel).

mass_to_total_fuel(Mass, TotalFuel) :-
  mass_to_total_fuel(Mass, 0, TotalFuel).

mass_to_total_fuel(Mass, Acc, TotalFuel) :-
  mass_to_fuel(Mass, ThisFuel),
  ( ThisFuel > 0
  -> mass_to_total_fuel(ThisFuel, ThisFuel + Acc, TotalFuel)
  ;  TotalFuel = Acc
  ).

