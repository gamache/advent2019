use_module(library(readutil)).

get_input_program(Program) :-
  read_file_to_string('input.txt', String, []),
  split_string(String, "\n", "\n", [Line1 | _]),
  split_string(Line1, ",", ",", Strings),
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
  part2(Program),
  print(done), nl.

part1(Program) :-
  execute(Program, [1], 0, _EndP, _EndV).

part2(Program) :-
  execute(Program, [5], 0, _EndP, _EndV).

execute(Program, Inputs, Position, EndProgram, EndValue) :-
  nth0(Position, Program, Opcode),
  print([execute, Opcode]), nl,
  execute_opcode(Opcode, Program, Inputs, Position, EndProgram, EndValue).

number_to_opcode(Number, Opcode) :-
  Cnum is div(Number, 10000),
  Bnum is div(Number, 1000) - 10*Cnum,
  Anum is div(Number, 100) - 100*Cnum - 10*Bnum,
  Instruction is Number - 10000*Cnum - 1000*Bnum - 100*Anum,
  number_mode(Anum, Amode),
  number_mode(Bnum, Bmode),
  number_mode(Cnum, Cmode),
  Opcode = [Number, Instruction, Amode, Bmode, Cmode].

number_mode(0, pos).
number_mode(1, imm).
number_mode(N, wtf) :-
  not(N = 1),
  not(N = 0).

apply_mode(Modes, ModeIndex, Position, Program, Value) :-
  Pos is Position + ModeIndex,
  nth1(ModeIndex, Modes, Mode),
  ( Mode = pos
    -> nth0(Pos, Program, [Pointer | _]),
       nth0(Pointer, Program, Value)
    ; nth0(Pos, Program, Value)
  ).

%% add
execute_opcode([_, 1 | Modes], Program, Inputs, Position, EndProgram, EndValue) :-
  apply_mode(Modes, 1, Position, Program, [X | _]),
  apply_mode(Modes, 2, Position, Program, [Y | _]),
  Ipos is Position + 3,
  nth0(Ipos, Program, [Index | _]),
  NextPos is Position + 4,
  Sum is X + Y,
  number_to_opcode(Sum, SumOpcode),
  list_nth0_item_replaced(Program, Index, SumOpcode, NextProgram),
  execute(NextProgram, Inputs, NextPos, EndProgram, EndValue).

%% multiply
execute_opcode([_, 2 | Modes], Program, Inputs, Position, EndProgram, EndValue) :-
  apply_mode(Modes, 1, Position, Program, [X | _]),
  apply_mode(Modes, 2, Position, Program, [Y | _]),
  Ipos is Position + 3,
  nth0(Ipos, Program, [Index | _]),
  NextPos is Position + 4,
  Product is X * Y,
  number_to_opcode(Product, ProductOpcode),
  list_nth0_item_replaced(Program, Index, ProductOpcode, NextProgram),
  execute(NextProgram, Inputs, NextPos, EndProgram, EndValue).

%% input
execute_opcode([_, 3 | _Modes], Program, [Input | Inputs], Position, EndProgram, EndValue) :-
  Ipos is Position + 1,
  nth0(Ipos, Program, [Index | _]),
  NextPos is Position + 2,
  number_to_opcode(Input, Opcode),
  list_nth0_item_replaced(Program, Index, Opcode, NextProgram),
  execute(NextProgram, Inputs, NextPos, EndProgram, EndValue).

%% output
execute_opcode([_, 4 | _Modes], Program, Inputs, Position, EndProgram, EndValue) :-
  Ipos is Position + 1,
  nth0(Ipos, Program, [Index | _]),
  nth0(Index, Program, [Value | _]),
  print([output, Value]), nl,
  NextPos is Position + 2,
  execute(Program, Inputs, NextPos, EndProgram, EndValue).

%% jump if true
execute_opcode([_, 5 | Modes], Program, Inputs, Position, EndProgram, EndValue) :-
  apply_mode(Modes, 1, Position, Program, [X | _]),
  apply_mode(Modes, 2, Position, Program, [Y | _]),
  (X = 0 -> NextPos is Position + 3 ; NextPos is Y),
  execute(Program, Inputs, NextPos, EndProgram, EndValue).

%% jump if false
execute_opcode([_, 6 | Modes], Program, Inputs, Position, EndProgram, EndValue) :-
  apply_mode(Modes, 1, Position, Program, [X | _]),
  apply_mode(Modes, 2, Position, Program, [Y | _]),
  (X = 0 -> NextPos is Y ; NextPos is Position + 3),
  execute(Program, Inputs, NextPos, EndProgram, EndValue).

%% less than
execute_opcode([_, 7 | Modes], Program, Inputs, Position, EndProgram, EndValue) :-
  apply_mode(Modes, 1, Position, Program, [X | _]),
  apply_mode(Modes, 2, Position, Program, [Y | _]),
  Ipos is Position + 3,
  nth0(Ipos, Program, [Index | _]),
  NextPos is Position + 4,
  (X < Y -> Value is 1 ; Value is 0),
  number_to_opcode(Value, Opcode),
  list_nth0_item_replaced(Program, Index, Opcode, NextProgram),
  execute(NextProgram, Inputs, NextPos, EndProgram, EndValue).

%% equals
execute_opcode([_, 8 | Modes], Program, Inputs, Position, EndProgram, EndValue) :-
  apply_mode(Modes, 1, Position, Program, [X | _]),
  apply_mode(Modes, 2, Position, Program, [Y | _]),
  Ipos is Position + 3,
  nth0(Ipos, Program, [Index | _]),
  NextPos is Position + 4,
  (X = Y -> Value is 1 ; Value is 0),
  number_to_opcode(Value, Opcode),
  list_nth0_item_replaced(Program, Index, Opcode, NextProgram),
  execute(NextProgram, Inputs, NextPos, EndProgram, EndValue).

%% halt
execute_opcode([_, 99 | _Modes], Program, _Inputs, _Position, EndProgram, EndValue) :-
  nth0(0, EndProgram, EndValue),
  EndProgram = Program.

