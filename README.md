## Introduction

Temperament-Math: calculate variegated circulating tuning temperaments.

Copyright (C) 2021 Mark D. Blackwell

## Usage

`ruby lib/TemperamentMath/calculate.rb`

Enter the generated tuning values into your tuner.
For example, I use Stichting Huygens-Fokker's program, Scala, to tune my harpsichord.

To generate more temperaments,
you can adjust the variables `fifth_max` and `fifth_min`,
found near the top of the program.

This program is known to work with version 2.7.0p0 (of Ruby).

## Explanation

The program generates tuning temperaments in which the major thirds are variegated.

In particular,
since each major third forms part of a major key's tonic chord,
each major third's tuning width increases
along with the number of sharps or flats in the key signature.
This resembles Thomas Young's first temperament.

Unlike Young's, however,
the sharp keys' major thirds are closer to just
than those of the corresponding flat keys,
which increases variety.
(Thomas Young had these the same.)

Unlike Young's,
the sharp keys are favored over the flat keys
(the major thirds are more just).

This improves the sound of the
major dominant chords of the commonly-used minor keys, such as
E-major in A-minor, A-major in D-minor,
B-major in E-minor, etc.

Also unlike Young's,
here the major third, CE is perfectly just.

## Notes on the program

x-sub-i is a numbered perfect fifth in the circle of fifths, rising to G, D, etc.:

x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12
G  D  A  E  B  F# C# G# D# A#  F   C

In this program, they are called @@fifth_1, etc.

n-sub-i is a numbered major third in the circle of fifths, again rising to G, D, etc.:

1    2    3    4    5    6    6    5    4     3    2     1
n4 < n5 < n3 < n6 < n2 < n7 < n1 < n8 < n12 < n9 < n11 < n10
E    B    A    F#   D    C#   G    G#   C     D#   F     A#

In this program, they are called @@third_1, etc.

The first line of numbers is the level number.

## License

GNU Affero General Public License, Version 3 (see [LICENSE](./LICENSE)).
