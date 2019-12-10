use_module(library(readutil)).

get_image(Width, Height, Image) :-
  read_file_to_string('input.txt', String, []),
  split_string(String, "\n", "\n", [Line1 | _]),
  string_chars(Line1, Chars),
  maplist(text_to_string, Chars, Strings),
  maplist(number_string, Pixels, Strings),
  LayerSize is Width * Height,
  length(Pixels, PixelCount),
  Layers is PixelCount / LayerSize,
  Image = [Width, Height, Layers, Pixels].

main :-
  get_image(25, 6, Image),
  find_fewest_zeroes(Image, Layer),
  layer_pixels(Image, Layer, Pixels),
  print([layer, Layer]), nl,
  count(Pixels, 1, Ones),
  count(Pixels, 2, Twos),
  Part1 is Ones * Twos,
  print([part1, Part1]), nl,

  merge_image(Image, Output),
  print_pixels(25, 6, Output),
  nl.

find_fewest_zeroes(Image, Layer) :-
  [Width, Height, Layers, _Pixels] = Image,
  StartLayer is Layers - 1,
  StartZeroes is Width * Height + 1,
  find_fewest_zeroes(Image, StartLayer, StartZeroes, 0, Layer).

find_fewest_zeroes(_Image, -1, _MinZeros, LayerAcc, Layer) :-
  Layer = LayerAcc.

find_fewest_zeroes(Image, CurLayer, MinZeros, LayerAcc, Layer) :-
  layer_pixels(Image, CurLayer, Pixels),
  count(Pixels, 0, Zeros),
  NextLayer is CurLayer - 1,
  ( Zeros < MinZeros
    -> find_fewest_zeroes(Image, NextLayer, Zeros, CurLayer, Layer)
    ; find_fewest_zeroes(Image, NextLayer, MinZeros, LayerAcc, Layer)
  ).

print_pixels(Width, Height, Pixels) :-
  X is Width - 1,
  Y is Height - 1,
  print_pixels(Width, Height, X, Y, Pixels).

print_pixels(_Width, _Height, _, -1, _Pixels).

print_pixels(Width, Height, -1, Y, Pixels) :-
  NextX is Width - 1,
  NextY is Y - 1,
  nl,
  print_pixels(Width, Height, NextX, NextY, Pixels).

print_pixels(Width, Height, X, Y, Pixels) :-
  %% it's easier to iterate in the opposite direction, so we flip coordinates
  FlipX is Width - X - 1,
  FlipY is Height - Y - 1,
  Pos is FlipY * Width + FlipX,
  NextX is X - 1,
  nth0(Pos, Pixels, Pixel),
  print(Pixel),
  print_pixels(Width, Height, NextX, Y, Pixels).

merge_image(Image, Output) :-
  [_Width, _Height, Layers, _Pixels] = Image,
  StartLayer is Layers - 2,
  TopLayer is Layers - 1,
  layer_pixels(Image, TopLayer, TopPixels),
  merge_image(Image, StartLayer, TopPixels, Output).

merge_image(_Image, -1, OutputAcc, Output) :-
  Output = OutputAcc.

merge_image(Image, Layer, OutputAcc, Output) :-
  NextLayer is Layer - 1,
  layer_pixels(Image, Layer, TopPixels),
  merge_layers(TopPixels, OutputAcc, NewOutputAcc),
  merge_image(Image, NextLayer, NewOutputAcc, Output).

merge_layers(TopLayer, BottomLayer, Output) :-
  maplist(merge_pixels, TopLayer, BottomLayer, Output).

merge_pixels(2, X, X).
merge_pixels(1, _, 1).
merge_pixels(0, _, 0).

layer_pixels(Image, Layer, Pixels) :-
  [Width, Height, _Layers, _ImagePixels] = Image,
  LayerOffset is Layer * Width * Height,
  X is Width - 1,
  Y is Height - 1,
  layer_pixels(Image, LayerOffset, X, Y, [], Pixels).

layer_pixels(Image, LayerOffset, 0, 0, PixelsAcc, Pixels) :-
  [_Width, _Height, _Layers, ImagePixels] = Image,
  nth0(LayerOffset, ImagePixels, Pixel),
  Pixels = [Pixel | PixelsAcc].

layer_pixels(Image, LayerOffset, 0, Y, PixelsAcc, Pixels) :-
  Y > 0,
  [Width, _Height, _Layers, ImagePixels] = Image,
  Pos is LayerOffset + (Y * Width),
  nth0(Pos, ImagePixels, Pixel),
  NewX is Width - 1,
  NewY is Y - 1,
  layer_pixels(Image, LayerOffset, NewX, NewY, [Pixel | PixelsAcc], Pixels).

layer_pixels(Image, LayerOffset, X, Y, PixelsAcc, Pixels) :-
  X > 0,
  [Width, _Height, _Layers, ImagePixels] = Image,
  Pos is LayerOffset + (Y * Width) + X,
  nth0(Pos, ImagePixels, Pixel),
  NewX is X - 1,
  layer_pixels(Image, LayerOffset, NewX, Y, [Pixel | PixelsAcc], Pixels).

count(Pixels, Digit, Count) :- count(Pixels, Digit, 0, Count).

count([], _Digit, CountAcc, Count) :- Count = CountAcc.

count([Pixel | Rest], Digit, CountAcc, Count) :-
  ( Pixel = Digit
    -> NewAcc is CountAcc + 1
    ; NewAcc is CountAcc
  ),
  count(Rest, Digit, NewAcc, Count).


