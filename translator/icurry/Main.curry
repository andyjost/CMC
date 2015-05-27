-- Convert FlatCurry to ICurry
-- Sergio Antoy
-- Mon Apr 28 10:51:09 PDT 2014

import System
import IO
import FlatCurry
import FlatCurryRead


import ICurry
import TypeTable
-- import VarTable
-- import CountRef
import PPFlat
import FlatToICurry
-- import PPICurry_Ex
import PPICurry
import FixCount
import RemoveInnerCases
import RemoveInnerLets

-- Some variables are never referenced and should not be declared

main = do
  args <- getArgs
  foldr ((>>) . process_file) (return ()) args

process_file file = do 
  flat <- readFlatCurry file
  {- putStrLn "--------- FLAT INITIAL ---------" -}
  {- putStrLn (PPFlat.execute flat) -}

  -- Find constructors used by the program, but defined in other modules.
  modules <- readFlatCurryIntWithImports file
  let type_table = TypeTable.execute modules
  {- putStrLn (ppTypeTable type_table) -}

  -- Replace case statements that are arguments of an application
  -- with new functions.
  let non_inner_cases = RemoveInnerCases.execute flat
  {- putStrLn "--------- NO INNER CASES ---------" -}
  {- putStrLn (PPFlat.execute non_inner_cases) -}

  -- Replace let-blocks that are arguments of an application
  -- with new functions.
  let non_inner_lets = RemoveInnerLets.execute non_inner_cases
  {- putStrLn "--------- NO INNER LETS ---------" -}
  {- putStrLn (PPFlat.execute non_inner_lets) -}

  -- construct a table of the variables used by each operation
  -- let var_tables = VarTable.execute non_inner_lets
  {- putStrLn "--------- PRELIM VAR TABLE ---------" -}
  {- ppVarTable var_tables -}
  -- putStrLn (show var_tables)

  -- let icurry = FlatToICurry.execute type_table var_tables non_inner_lets
  let icurry = FlatToICurry.execute type_table non_inner_lets
  let n = FixCount.execute icurry
  -- force the execution of FixCount
  icurry_handle <- seq n (openFile (file ++ ".icur") WriteMode)
  hPutStr icurry_handle (show icurry)
  hClose icurry_handle

  {- putStrLn "--------- ICURRY ---------" -}
  {- putStrLn (show icurry) -}
  {- putStrLn (PPICurry_Ex.execute icurry) -}
  read_handle <- openFile (file ++ ".read") WriteMode
  -- hPutStrLn read_handle (PPICurry_Ex.execute icurry)
  hPutStrLn read_handle (PPICurry.execute icurry)
  hClose read_handle
