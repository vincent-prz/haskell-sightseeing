{-# OPTIONS_GHC -Wall #-}
{- CIS 194 HW 10
   due Monday, 1 April
-}

module AParser where

import           Control.Applicative

import           Data.Char

-- A parser for a value of type a is a function which takes a String
-- represnting the input to be parsed, and succeeds or fails; if it
-- succeeds, it returns the parsed value along with the remainder of
-- the input.
newtype Parser a = Parser { runParser :: String -> Maybe (a, String) }

-- For example, 'satisfy' takes a predicate on Char, and constructs a
-- parser which succeeds only if it sees a Char that satisfies the
-- predicate (which it then returns).  If it encounters a Char that
-- does not satisfy the predicate (or an empty input), it fails.
satisfy :: (Char -> Bool) -> Parser Char
satisfy p = Parser f
  where
    f [] = Nothing    -- fail on the empty input
    f (x:xs)          -- check if x satisfies the predicate
                        -- if so, return x along with the remainder
                        -- of the input (that is, xs)
        | p x       = Just (x, xs)
        | otherwise = Nothing  -- otherwise, fail

-- Using satisfy, we can define the parser 'char c' which expects to
-- see exactly the character c, and fails otherwise.
char :: Char -> Parser Char
char c = satisfy (== c)

{- For example:

*Parser> runParser (satisfy isUpper) "ABC"
Just ('A',"BC")
*Parser> runParser (satisfy isUpper) "abc"
Nothing
*Parser> runParser (char 'x') "xyz"
Just ('x',"yz")

-}

-- For convenience, we've also provided a parser for positive
-- integers.
posInt :: Parser Integer
posInt = Parser f
  where
    f xs
      | null ns   = Nothing
      | otherwise = Just (read ns, rest)
      where (ns, rest) = span isDigit xs

------------------------------------------------------------
-- Your code goes below here
------------------------------------------------------------

-- Ex 1
first :: (a -> b) -> Maybe (a, c) -> Maybe (b, c)
first _ Nothing = Nothing
first f (Just (x ,y)) = Just (f x, y)

instance Functor Parser where
  fmap f parser = Parser ((first f) . (runParser parser))

-- Ex 2
first' :: Maybe (a -> b,  String) -> Maybe(a, String) -> Maybe(b, String)
first' Nothing _                 = Nothing
first' _ Nothing                 = Nothing
first' (Just(f, _)) (Just(x, s)) = Just(f x, s)

instance Applicative Parser where
  pure x = Parser (\s -> Just (x, s))
  Parser f <*> p = Parser (\s ->
    case f s of
      Nothing -> Nothing
      Just(g, s') -> first g ((runParser p) s')
    )
-- Ex 3
abParser :: Parser (Char, Char)
abParser = (\x y -> (x, y)) <$> (satisfy (=='a')) <*> (satisfy (=='b'))

--
abParser_ :: Parser ()
abParser_ = (\_ _ -> ()) <$> (satisfy (=='a')) <*> (satisfy (=='b'))

--
intPair :: Parser [Integer]
intPair = (\x _ y -> [x, y]) <$> posInt <*> (satisfy (==' ')) <*> posInt
