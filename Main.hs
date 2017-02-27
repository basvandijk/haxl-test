{-# language MultiParamTypeClasses #-}
{-# language FlexibleInstances #-}
{-# language DeriveDataTypeable #-}
{-# language GADTs #-}
{-# language TypeFamilies #-}
{-# language OverloadedStrings #-}
{-# language ApplicativeDo #-}

module Main where

import Haxl.Core hiding (try)
import Data.Hashable
import Data.Typeable
import Data.Foldable
import Control.Monad.Catch
import Control.Monad

main :: IO ()
main = do
    let stateStore = stateSet MyRequestSt stateEmpty
    env <- initEnv stateStore ()
    runHaxl env haxl

haxl :: GenHaxl () ()
haxl = do
    myPutStrLn "Hello"
    throwM MyException
    myPutStrLn "World!"
    pure ()

myPutStrLn :: String -> GenHaxl () ()
myPutStrLn str = dataFetch (PutStrLn str)

data MyRequest a where
    PutStrLn :: String -> MyRequest ()
    deriving (Typeable)

data MyException = MyException deriving (Show, Typeable)

instance Exception MyException

instance Eq (MyRequest ()) where
    PutStrLn str1 == PutStrLn str2 = str1 == str2

instance Show (MyRequest ()) where
    show (PutStrLn str) = "PutStrLn " ++ show str

instance ShowP MyRequest where
    showp (PutStrLn str) = "PutStrLn " ++ show str

instance Hashable (MyRequest ()) where
    hashWithSalt s (PutStrLn str) = s `hashWithSalt` (0 :: Int) `hashWithSalt` str

instance DataSource () MyRequest where
    fetch st flags () fetches = SyncFetch $ traverse_ performRequest fetches
        where
          performRequest :: BlockedFetch MyRequest -> IO ()
          performRequest (BlockedFetch (PutStrLn str) resultVar) = do
            r <- try (putStrLn str)
            putResult resultVar r

instance DataSourceName MyRequest where
    dataSourceName _req = "MyRequest"

instance StateKey MyRequest where
    data State MyRequest = MyRequestSt
