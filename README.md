# Ludum Dare Game Results History Generator
Lua script to generate a table showing your LD results over time

Example:
```
Note that the rating percentage is only a rough guess.
┌───────────┬───────────────────────┬─────────────────┬─────────────────┬─────────────────┬─────────────────┬─────────────────┬─────────────────┬─────────────────┬─────────────────┐
│    LD     │         Game          │     Overall     │       Fun       │   Innovation    │      Theme      │    Graphics     │      Audio      │      Humor      │      Mood       │
├───────────┼───────────────────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────┤
│  44, jam  │ The Healthy Gladiator │  914/1169 - 22% │  931/1169 - 20% │  701/1169 - 40% │  720/1169 - 38% │  956/1169 - 18% │       N/A       │       N/A       │       N/A       │
│  45, jam  │   Trick or Retreat    │  910/1189 - 23% │  545/1189 - 54% │  916/1189 - 23% │ 1038/1189 - 12% │  938/1189 - 21% │       N/A       │  325/1189 - 72% │  798/1189 - 33% │
│ 46, compo │    Beware the Dark    │  802/1288 - 37% │  601/1288 - 53% │  610/1288 - 52% │  980/1288 - 24% │  715/1288 - 44% │  295/1288 - 77% │       N/A       │  111/1288 - 91% │
│ 47, compo │   Pi's Great Escape   │  559/ 712 - 21% │  498/ 712 - 30% │  328/ 712 - 54% │  499/ 712 - 30% │  533/ 712 - 25% │  416/ 712 - 41% │  217/ 712 - 69% │  525/ 712 - 26% │
│ 48, compo │    Backwards Quest    │  742/1079 - 31% │  721/1079 - 33% │  440/1079 - 59% │  782/1079 - 27% │  760/1079 - 29% │  441/1079 - 59% │  228/1079 - 79% │  596/1079 - 45% │
└───────────┴───────────────────────┴─────────────────┴─────────────────┴─────────────────┴─────────────────┴─────────────────┴─────────────────┴─────────────────┴─────────────────┘
```
(Made with https://github.com/LoneWolfHT/ld-results-history)

Usage:
* git clone --recursive <this repository>
* Install luarocks and lua
* Run `luarocks install http` and `luarocks install lua-json`
* Run `lua ./ld-results.lua <game name>, <game2 name>, ...`
