{-# LANGUAGE OverloadedStrings #-}

module Main where
import qualified Data.Text.IO as TIO
import qualified Data.Text as T
import Network.HTTP.Conduit
import qualified Data.Text.Encoding as TE
import qualified Data.ByteString.Lazy.Char8 as LBS
import Data.List
import System.Console.ANSI
import System.Directory (getDirectoryContents)
import System.FilePath ( takeExtension)

listCabalFiles :: FilePath -> IO [FilePath]
listCabalFiles dir = do
    contents <- getDirectoryContents dir
    return $ filter (\f -> takeExtension f == ".cabal") contents

listHsFiles :: FilePath -> IO [FilePath]
listHsFiles dir = do
    contents <- getDirectoryContents dir
    return $ filter (\f -> takeExtension f == ".hs") contents

removeQuotesAndSlashes :: T.Text -> T.Text
removeQuotesAndSlashes = T.replace "\"" "" . T.replace "\\" ""

removeComments :: [T.Text] -> [T.Text]
removeComments input = filter (\x -> not (T.isInfixOf "--" x)) input

splitOnNewLine :: T.Text -> [T.Text]
splitOnNewLine input = T.splitOn "\n" input

splitOnComma :: T.Text -> [T.Text]
splitOnComma input = T.splitOn "," input

addWithNewLines :: [T.Text] -> [T.Text]
addWithNewLines input = map (`T.append` "\n") input

replaceWithComma :: T.Text -> T.Text
replaceWithComma input = T.replace "build-depends:" "build-depends:," (T.replace "extra-libraries:" "extra-libraries:," input)

trimEmpty :: [[T.Text]] -> [[T.Text]]
trimEmpty input = map ( \x-> map T.strip x ) input

dropEmpty :: [[T.Text]] -> [[T.Text]]
dropEmpty input = map (\x -> dropWhile (=="") x) input

getHeads :: [[T.Text]] -> [T.Text]
getHeads input = map head input

removeVersions :: T.Text -> T.Text
removeVersions input = head (T.splitOn "^" (head (T.splitOn "=" (head (T.splitOn ">" (head (T.splitOn "<" input)))))))

cveAnalysis :: FilePath -> IO()
cveAnalysis filepath = do
        fileContent <- TIO.readFile filepath
        putStrLn ("\n Analyzing " ++ filepath) 

        let split_output = splitOnNewLine fileContent

        let no_comments = removeComments split_output

        let add_new_lines = addWithNewLines no_comments

        let new_string = T.concat add_new_lines

        let with_commas = replaceWithComma new_string

        let comma_splits = splitOnComma with_commas

        let final_newline_split = map splitOnNewLine comma_splits

        let trimmed_empty = trimEmpty final_newline_split

        let empty_dropped = dropEmpty trimmed_empty

        let head_gotten = getHeads empty_dropped

        let drop_first = nub (tail head_gotten)

        let no_verisons = map removeVersions drop_first

        let route = "http://0.0.0.0:8000/search?term=" :: String

        let urls= map (\x->route ++ T.unpack (x)) no_verisons

        responses <- mapM simpleHttp urls

        let converted_resposnes = map (TE.decodeUtf8 . LBS.toStrict) responses

        let trimmed_responses =map removeQuotesAndSlashes converted_resposnes

        let pairs = zip no_verisons trimmed_responses

        mapM_ output_vulnerabilities pairs




output_vulnerabilities :: (T.Text, T.Text) -> IO()
output_vulnerabilities input = do
    if T.isInfixOf "No vulnerabilities found" ( (snd input))
        then
        setSGR [SetColor Foreground Dull Green] >>  
        putStrLn (" -- "++T.unpack (fst input) ++ " -- "++ (T.unpack (snd input)))
        else
        setSGR [SetColor Foreground Dull Red] >> 
        putStrLn (" -- "++T.unpack (fst input) ++ " -- "++ (T.unpack (snd input)))



printLogo :: Int -> IO()
printLogo x= do
    setSGR [SetColor Background Dull Magenta]
    putStrLn " __         ______     __    __     ______     _____     ______                                              "
    putStrLn "/\\ \\       /\\  __ \\   /\\ \ \ \\./  \\   /\\  == \\   /\\  __-.  /\\  __ \\                         "
    putStrLn "\\ \\ \\____  \\ \\  __ \\  \\ \\ \\-./\\ \\  \\ \\  __<   \\ \\ \\/\\ \\ \\ \\  __ \\                       "
    putStrLn " \\ \\_____\\  \\ \\_\\ \\_\\  \\ \\_\\ \\ \\_\\  \\ \\_____\\  \\ \\____-  \\ \\_\\ \\_\\                      "
    putStrLn "  \\/_____/   \\/_/\\/_/   \\/_/  \\/_/   \\/_____/   \\/____/   \\/_/\\/_/                    "
    putStrLn "                                                                                               "
    putStrLn "                      ______     __  __     ______     ______     __  __                       "
    putStrLn "                     /\\  ___\\   /\\ \\_\\ \\   /\\  ___\\   /\\  ___\\   /\\ \\/ /           "
    putStrLn "                     \\ \\ \\____  \\ \\  __ \\  \\ \\  __\\   \\ \\ \\____  \\ \\  _\"-.      "
    putStrLn "                      \\ \\_____\\  \\ \\_\\ \\_\\  \\ \\_____\\  \\ \\_____\\  \\ \\_\\ \\_\\ "
    putStrLn "                       \\/_____/   \\/_/\\/_/   \\/_____/   \\/_____/   \\/_/\\/_/             "
-- Ends the Highlighted Section
    putStrLn "\x1b[49m"
    putStrLn ""

weaknessAnalysis :: FilePath -> IO()
weaknessAnalysis filePath =do
    fileContent <- TIO.readFile filePath
    setSGR [SetColor Foreground Dull White] >> putStrLn ("\n Analyzing " ++ filePath) 
    let lines = T.splitOn "\n" fileContent
    let tuples = zip lines [1,2..]
    mapM_ weaknessOutput tuples

weaknessOutput :: (T.Text,Int)-> IO()
weaknessOutput input = do
    if T.isInfixOf "import Unsafe.Coerce" (fst input)
        then 
            setSGR [SetColor Foreground Dull Red] >>
            putStrLn ("\n-- Utilization of unsafeCoerce in type change operations can result in segmenation faults and data corruption. Error on line " ++ show (snd input))
        else 
            setSGR [SetColor Foreground Dull Green] >>
            -- putStrLn ("-- No risk of unsafeCoerce segmentaion faults! Line " ++ show (snd input))
            putStr " * "
    if T.isInfixOf "peek" (fst input) && T.isInfixOf "import Foreign.Ptr" (fst input)
        then 
            setSGR [SetColor Foreground Dull Red] >>
            putStrLn ("\n-- Using peek on a foreign pointer can cause a segmentation fault, if null pointer segmentation fault is guaranteed. Error on line "++ show (snd input)) 
        else 
            setSGR [SetColor Foreground Dull Green] >>            
            -- putStrLn ("-- No risk of derefrenceing null pointer with peek! Line "++ show (snd input))
            putStr " * "
    if T.isInfixOf "IORef" (fst input)
        then 
            setSGR [SetColor Foreground Dull Red] >>
            putStrLn ("\n-- Program is using mutable state via IORef which are vulnerable to buffer overflow. Error on line "++ show (snd input))
        else 
            setSGR [SetColor Foreground Dull Green] >>
            -- putStrLn ("-- No risk of buffer overflow from IORef! Line "++ show (snd input))
            putStr " * "
    if T.isInfixOf "foreign import" (fst input)
        then 
            setSGR [SetColor Foreground Dull Red] >>
            putStrLn( "\n-- Foreign library import detected, non native libraties are more vulnerable to segmentaion faults and buffer overflows. Error on line "++ show (snd input))
        else 
            setSGR [SetColor Foreground Dull Green] >>
            -- putStrLn ("-- Foreign imports not found! Line "++ show (snd input))
            putStr " * "
    if T.isInfixOf "IORef" (fst input) && T.isInfixOf "import Control.Concurent" (fst input) && T.isInfixOf "forkIO" (fst input)
        then 
            setSGR [SetColor Foreground Dull Red] >>
            putStrLn ("\n-- IORef is Unsafe for threads. Does not use up/down blocks to prevent race conditions. Use MVar instead. Error on line "++ show (snd input))
        else 
            setSGR [SetColor Foreground Dull Green] >>
            -- putStrLn ("-- Safe from thread IORef race conditions. Line "++ show (snd input))
            putStr " * "
    if not(T.isInfixOf "import Control.Cuncurent.STM" (fst input)) && not(T.isInfixOf "atomically" (fst input)) && T.isInfixOf "forkIO" (fst input)
        then 
            setSGR [SetColor Foreground Dull Red] >>
            putStrLn ("\n-- Warning. Using forkIO non atomically can lead to race conditions. Error on line "++ show (snd input))
        else 
            setSGR [SetColor Foreground Dull Green] >>
            -- putStrLn ("-- Safe from non atomic forkIO race conditions "++ show (snd input))
            putStr " * "
    putStrLn ""
main :: IO ()
main = do
    printLogo 1
    cabalFiles <- listCabalFiles "."
    mapM_ cveAnalysis cabalFiles
    hsFiles <- listHsFiles "."
    mapM_ weaknessAnalysis hsFiles

