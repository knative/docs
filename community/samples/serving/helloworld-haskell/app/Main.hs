{-# LANGUAGE OverloadedStrings #-}

import           Data.Maybe
import           Data.Monoid        ((<>))
import           Data.Text.Lazy     (Text)
import           Data.Text.Lazy
import           System.Environment (lookupEnv)
import           Web.Scotty         (ActionM, ScottyM, scotty)
import           Web.Scotty.Trans

main :: IO ()
main = do
  t <- fromMaybe "World" <$> lookupEnv "TARGET"
  pStr <- fromMaybe "8080" <$> lookupEnv "PORT"
  let p = read pStr :: Int
  scotty p (route t)

route :: String -> ScottyM()
route t = get "/" $ hello t

hello :: String -> ActionM()
hello t = text $ pack ("Hello " ++ t)
