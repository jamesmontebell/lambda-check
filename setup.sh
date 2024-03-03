#!/bin/bash


cd CLI

curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

cabal build

cabal run

echo " alias = \" ~/lambda-check/CLI/dist-newstyle/build/*/ghc-8.8.4/Lambda-Check-0.1.0.0/x/Lambda-Check/build/Lambda-Check \" " >> ~/.bashrc

pip install sqlite3
pip install fastapi

source ~/.bashrc

cabal install text
cabal install http-conduit
cabal install bytestring
cabal install ansi-terminal

