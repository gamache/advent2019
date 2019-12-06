use_module(library(readutil)).

get_input_program(Program) :-
  read_file_to_string('../02/input.txt', String, []),
  split_string(String, ",", ",", Strings),
  maplist(number_string, Numbers, Strings),
  maplist(number_to_opcode, Numbers, Program).

% I got this from Stack Overflow
list_nth0_item_replaced(Es, N, X, Xs) :-
  same_length(Es, Xs),
  append(Prefix, [_|Suffix], Es),
  length(Prefix, N),
  append(Prefix, [X|Suffix], Xs).

main :-
  get_input_program(Program),
  part1(Program),
%  part2(Program),
  print(done), nl.

part1(Program) :-
  apply_inputs_and_execute(12, 2, Program, _EndProgram, EndValue),
  print(EndValue), nl.

part2(Program) :-
  between(0, 99, Noun),
  between(0, 99, Verb),
  apply_inputs_and_execute(Noun, Verb, Program, _End2, 19690720),
  X is 100 * Noun + Verb,
  print(X), nl.

apply_inputs_and_execute(Input1, Input2, Program, EndProgram, EndValue) :-
  number_to_opcode(Input1, Opcode1),
  number_to_opcode(Input2, Opcode2),
  list_nth0_item_replaced(Program, 1, Opcode1, Program1),
  list_nth0_item_replaced(Program1, 2, Opcode2, Program2),
  execute(Program2, 0, EndProgram, EndValue).

execute(Program, Position, EndProgram, EndValue) :-
  nth0(Position, Program, Opcode),
  %print([execute, Opcode, Program, Position]), nl,
  execute_opcode(Opcode, Program, Position, EndProgram, EndValue).

number_to_opcode(Number, Opcode) :-
  Anum is div(Number, 10000),
  Bnum is div(Number, 1000) - 10*Anum,
  Cnum is div(Number, 100) - 100*Anum - 10*Bnum,
  Instruction is Number - 10000*Anum - 1000*Bnum - 100*Cnum,
  number_mode(Anum, Amode),
  number_mode(Bnum, Bmode),
  number_mode(Cnum, Cmode),
  Opcode = [Number, Instruction, Amode, Bmode, Cmode].

number_mode(0, position).
number_mode(1, immediate).
number_mode(N, dunno) :-
  not(N = 1),
  not(N = 0).

apply_mode(Modes, ModeIndex, Position, Program, Value) :-
  Pos is Position + ModeIndex,
  nth1(ModeIndex, Modes, Mode),
  ( Mode = position
    -> nth0(Pos, Program, [Pointer | _]),
       nth0(Pointer, Program, Value)
    ; nth0(Pos, Program, Value)
  ).

%% add
execute_opcode([_, 1 | Modes], Program, Position, EndProgram, EndValue) :-
  apply_mode(Modes, 1, Position, Program, [X | _]),
  apply_mode(Modes, 2, Position, Program, [Y | _]),
  Ipos is Position + 3,
  nth0(Ipos, Program, [Index | _]),
  NextPos is Position + 4,
  Sum is X + Y,
  number_to_opcode(Sum, SumOpcode),
  list_nth0_item_replaced(Program, Index, SumOpcode, NextProgram),
  execute(NextProgram, NextPos, EndProgram, EndValue).

%% multiply
execute_opcode([_, 2 | Modes], Program, Position, EndProgram, EndValue) :-
  apply_mode(Modes, 1, Position, Program, [X | _]),
  apply_mode(Modes, 2, Position, Program, [Y | _]),
  Ipos is Position + 3,
  nth0(Ipos, Program, [Index | _]),
  NextPos is Position + 4,
  Product is X * Y,
  number_to_opcode(Product, ProductOpcode),
  list_nth0_item_replaced(Program, Index, ProductOpcode, NextProgram),
  execute(NextProgram, NextPos, EndProgram, EndValue).

%% halt
execute_opcode([_, 99 | _], Program, _Position, EndProgram, EndValue) :-
  nth0(0, EndProgram, EndValue),
  EndProgram = Program.

