{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_Lambda_Check (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/omniladder/.cabal/bin"
libdir     = "/home/omniladder/.cabal/lib/x86_64-linux-ghc-8.8.4/Lambda-Check-0.1.0.0-inplace-Lambda-Check"
dynlibdir  = "/home/omniladder/.cabal/lib/x86_64-linux-ghc-8.8.4"
datadir    = "/home/omniladder/.cabal/share/x86_64-linux-ghc-8.8.4/Lambda-Check-0.1.0.0"
libexecdir = "/home/omniladder/.cabal/libexec/x86_64-linux-ghc-8.8.4/Lambda-Check-0.1.0.0"
sysconfdir = "/home/omniladder/.cabal/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "Lambda_Check_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "Lambda_Check_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "Lambda_Check_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "Lambda_Check_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "Lambda_Check_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "Lambda_Check_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
