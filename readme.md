# Taste Integration glue-code

This software must be integrated and shipped within the `ilk-compiler` tool.

## Authors

ESROCOS-KUL team:
  * Enea Scioni, <enea.scioni@kuleven.be>
  * Pawel Pazderski, <pawel.pazderski@kuleuven.be>
  * Marco Frigerio, <marco.frigerio@kuleuven.be>

## Requirements

This software requires:
  * `lua-common-tools`: luarock shipped in `luarocks` folder
  * `yaml`: shipped with luarocks (tested 1.1.2-1)
  * `luafilesystem`: shipped with luarocks (tested 1.7.0-2)

To install Lua modules, it is suggested the usage of Luarocks.
All tested with Lua5.2.

## Content

  * `GenerateTasteBlock.lua`: the main executable of the tool

## Usage

1. Customize `config.yml`.
2. Copy `metadata.yml` file generated by the `ilk-compiler`
3. Run `./GenerateTasteBlock.lua`.