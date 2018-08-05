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
  t <- fromMaybe "NOT SPECIFIED" <$> lookupEnv "TARGET"
  scotty 8080 (route t)

route :: String -> ScottyM()
route t = get "/" $ hello t

hello :: String -> ActionM()
hello t = text $ pack ("Hello world: " ++ t)
