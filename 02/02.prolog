use_module(library(readutil)).

get_input_numbers(Numbers) :-
  read_file_to_string('input.txt', String, []),
  split_string(String, ",", ",", Strings),
  maplist(number_string, Numbers, Strings).

% I got this from Stack Overflow
list_nth0_item_replaced(Es, N, X, Xs) :-
  same_length(Es, Xs),
  append(Prefix, [_|Suffix], Es),
  length(Prefix, N),
  append(Prefix, [X|Suffix], Xs).

main :-
  get_input_numbers(Program),
  apply_inputs_and_execute(12, 2, Program, _EndProgram, EndValue),
  print(EndValue), nl,

  between(0, 99, Noun),
  between(0, 99, Verb),
  apply_inputs_and_execute(Noun, Verb, Program, _End2, 19690720),
  X is 100 * Noun + Verb,
  print(X), nl.

apply_inputs_and_execute(Input1, Input2, Program, EndProgram, EndValue) :-
  list_nth0_item_replaced(Program, 1, Input1, Program1),
  list_nth0_item_replaced(Program1, 2, Input2, Program2),
  execute(Program2, 0, EndProgram, EndValue).

execute(Program, Position, EndProgram, EndValue) :-
  nth0(Position, Program, Opcode),
  execute_opcode(Opcode, Program, Position, EndProgram, EndValue).

execute_opcode(1, Program, Position, EndProgram, EndValue) :-
  Xpos is Position + 1,
  nth0(Xpos, Program, X),
  nth0(X, Program, Xval),

  Ypos is Position + 2,
  nth0(Ypos, Program, Y),
  nth0(Y, Program, Yval),

  Ipos is Position + 3,
  nth0(Ipos, Program, Index),

  NextPos is Position + 4,

  Sum is Xval + Yval,
  list_nth0_item_replaced(Program, Index, Sum, NextProgram),
  execute(NextProgram, NextPos, EndProgram, EndValue).

execute_opcode(2, Program, Position, EndProgram, EndValue) :-
  Xpos is Position + 1,
  nth0(Xpos, Program, X),
  nth0(X, Program, Xval),

  Ypos is Position + 2,
  nth0(Ypos, Program, Y),
  nth0(Y, Program, Yval),

  Ipos is Position + 3,
  nth0(Ipos, Program, Index),

  NextPos is Position + 4,

  Product is Xval * Yval,
  list_nth0_item_replaced(Program, Index, Product, NextProgram),
  execute(NextProgram, NextPos, EndProgram, EndValue).

execute_opcode(99, Program, _Position, EndProgram, EndValue) :-
  nth0(0, EndProgram, EndValue),
  EndProgram = Program.

