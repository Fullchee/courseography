{-# LANGUAGE EmptyDataDecls             #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}

import           Control.Monad.IO.Class  (liftIO)
import           Control.Monad.Logger    (runStderrLoggingT)
import           Database.Persist
import           Database.Persist.Postgresql
import           Database.Persist.TH
import qualified Data.ByteString.Lazy as B
import Data.Text
import Data.Aeson
import GHC.Generics
import System.Directory	
import Control.Monad.Logger
import Control.Monad.Trans.Resource.Internal
import Control.Monad.Trans.Reader
import Control.Monad
import Control.Applicative

connStr = "host=localhost dbname=coursedb user=cynic password=**** port=5432"

data Lecture =
    Lecture { extra      :: Int,
              section    :: String,
              cap        :: Int,
              time_str   :: String,
              time       :: [[Int]],
              instructor :: String,
              enrol      :: Int,
              wait       :: Int
            } deriving (Show)

data Tutorial =
    Tutorial { times   :: [[Int]],
               timeStr :: String
             } deriving (Show)

data Session =
    Session { tutorials :: [Lecture],
              lectures  :: [[Tutorial]]
            } deriving (Show)

data Course = 
    Course { breadth               :: !Text,
             description           :: !Text,
             title               :: !Text,
             prereqString        :: Maybe Text,
             f                   :: Maybe Session,
             s                   :: Maybe Session,
             name                :: !Text,
             exclusions          :: Maybe Text,
             manualTutorialEnrol :: Maybe Bool,
             distribution        :: !Text,
             prereqs             :: Maybe [Text]
	   } deriving (Show, Generic)

fileJ :: FilePath
fileJ = "./file.json"

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Courses
    department String
    code Int
    breadth Int
    title String
    description String
    manualTutorialEnrolment Bool
    manualPracticalEnrolment Bool
    prereqs [String]
    exclusions [String]
    distribution Int
    prep String
    deriving Show

Lectures
    department String
    code Int
    session String
    lid String
    times [Int] - [[]]
    capacity Int
    enrolled Int
    waitlist Int
    extra Int
    location String
    time_str String
    deriving Show

Tutorials
    department String
    cNum Int
    tId String
    times [Int] -- [[]]
    deriving Show

Breadth
    bId Int
    description String
    deriving Show

Distribution
    -- dId Int
    description String
    deriving Show
|]

main :: IO ()
main = runStderrLoggingT $ withPostgresqlPool connStr 10 $ \pool ->
    liftIO $ do
    flip runSqlPersistMPool pool $ do
        runMigration migrateAll
--        processDirectory $ "../../copy/courses"
        insert $ Distribution "David"
        liftIO $ processDirectory $ "../../copy/courses"

instance FromJSON Course where
    parseJSON (Object v) = 
        Course <$> v .: "breadth"
               <*> v .: "description"
               <*> v .: "title"
               <*> v .: "prereqString"
               <*> v .:? "F"
               <*> v .:? "S"
               <*> v .: "name"
               <*> v .: "exclusions"
               <*> v .:? "manualTutorialEnrolment"
               <*> v .: "distribution"
               <*> v .:? "prereqs"
    parseJSON _ = mzero

instance FromJSON Session where
    parseJSON (Object v) =
        Session <$> v .: "lectures"
                <*> v .: "tutorials"
    parseJSON _ = mzero    

instance FromJSON Lecture where
    parseJSON (Object v) =
        Lecture <$> v .: "extra"
                <*> v .: "section"
                <*> v .: "cap"
                <*> v .: "time_str"
                <*> v .: "time"
                <*> v .: "instructor"
                <*> v .: "enrol"
                <*> v .: "wait"
    parseJSON _ = mzero

instance FromJSON Tutorial where
    parseJSON (Object v) =
        Tutorial <$> v .: "times"
                 <*> v .: "timeStr"
    parseJSON _ = mzero

printDirectory :: String -> IO ()
printDirectory x = do 
                       files <- getDirectoryContents x
                       print files

processDirectory :: String -> IO ()
processDirectory x = do
                       files <- getDirectoryContents x
                       printFiles files

printFiles :: [String] -> IO ()
printFiles [] = print "Done"
printFiles (x:xs) = do
                      f <- doesFileExist $ "../../copy/courses/" ++ x
                      if f 
                      then do 
                             d <- (eitherDecode <$> (getJSON ("../../copy/courses/" ++ x))) :: IO (Either String [Course])
                             case d of
                               Left err -> putStrLn err
                               Right ps -> print ("Good")
                      else print "Directory"
                      printFiles xs 

openJSON :: B.ByteString
openJSON = "["

closeJSON :: B.ByteString
closeJSON = "]"

getJSON :: String -> IO B.ByteString
getJSON jsonFile = do
                     a <- (B.readFile jsonFile)
                     let b = B.append openJSON a
                     let c = B.append b closeJSON
		     return c
