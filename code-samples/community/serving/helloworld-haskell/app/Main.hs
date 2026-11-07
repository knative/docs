{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Data.Maybe (fromMaybe)
import Data.Text.Lazy (pack)
import System.Environment (lookupEnv)
import Text.Read (readMaybe)
import Web.Scotty (get, scotty, text)

main :: IO ()
main = do
  target <- fromMaybe "World" <$> lookupEnv "TARGET"
  portText <- fromMaybe "8080" <$> lookupEnv "PORT"
  case readMaybe portText :: Maybe Int of
    Just port | port >= 1 && port <= 65535 ->
      scotty port $ get "/" $ text $ pack ("Hello " ++ target)
    _ -> fail "PORT must be an integer between 1 and 65535"
