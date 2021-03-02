## Introduction

Temperament-Math: calculate variegated circulating tuning temperaments.

Copyright (C) 2021 Mark D. Blackwell

## Usage

`ruby lib/TemperamentMath/Calculate/calculate.rb <maximum fifth> <minimum fifth>`

A possible starting place is to use `2` and `-2`.

Then look in directory `out/` for the generated fifth sets,
which will be in a file, in this case, of the form `*p2-n2-fifth*`.

Select one; then do:

`ruby lib/TemperamentMath/Tuning/tuning.rb <strength> <fifth set>`

There's no need to place single (or double) quotation marks around the fifth set.

The strength is a multiple of 10, from 0 to 100, and indicates percentage. 0% is always equal temperament.

Then you can enter the generated tuning values into your tuner.
For example, I use Stichting Huygens-Fokker's program, Scala, to tune my harpsichord.

To generate more temperaments, you can adjust the program arguments.

This program is known to work with version 2.7.0p0 (of Ruby).

## Explanation

The program generates many keyboard tuning temperaments
in which the major thirds are variegated.

Tuning to a variegated temperament adds richness to the listener's experience.

In particular, in this program,
since each major third forms part of some major key's tonic chord,
the tuning adjustment of major thirds co-varies
with the number of sharps or flats in that key signature.
Thomas Young's first temperament is a good example of this principle.

Better than Young's, however, in this program
the sharped key signatures' tonic major thirds are closer to just,
than those of the corresponding flatted key signatures
(that is, with the same number of sharps or flats).
This increases variety.
(In Young's, on the other hand, they are the same.)

So, here,
the sharp keys are favored over the flat keys
(because their tonic major thirds are closer to just).
This improves the sound of the
(major) dominant chords of commonly-used minor keys.
For example:

* The dominant E-major chord (4 sharps) of A minor (no sharps);

* The A-major chord (3 sharps) of D minor (1 flat); and

* The B-major chord (5 sharps) of E minor (1 sharp).

Also unlike Young's, in this program,
the major third CE is perfectly just.
Young's only comes fairly close.

## Notes on the program

`x-sub-i` is a numbered perfect fifth in the circle of fifths, rising to G, D, etc.:

    x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12
    G  D  A  E  B  F# C# G# D# A#  F   C

In this program, they are called `@@fifth_1`, etc.

`n-sub-i` is a numbered major third in the circle of fifths, again rising to G, D, etc.:

    1    2    3    4    5    6    6    5    4     3    2     1
    n4 < n5 < n3 < n6 < n2 < n7 < n1 < n8 < n12 < n9 < n11 < n10
    E    B    A    F#   D    C#   G    G#   C     D#   F     A#

In this program, they are called `@@third_1`, etc.

The first line of numbers is called, in the program, the "level" number.

## License

GNU Affero General Public License, Version 3 (see [LICENSE](./LICENSE)).
