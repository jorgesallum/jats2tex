{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

module Text.JaTexSpec where

import Data.String.Here
import qualified Data.Text as Text

import Test.Hspec

import Text.JaTex
import Text.JaTex.Template.Types
import Text.JaTex.TexWriter

spec :: Spec
spec = do
  describe "readJats" $ do
    it "works" $ do
      doc <- parseJATS [here|<strong>Hello</strong>|]
      templ <- parseTemplate "<noname>" [here|strong: "\\textbf{@@children}"|]
      output <-
        jatsXmlToLaTeXText
          def {joInputDocument = doc, joTemplate = (templ, "<noname>")}
      output `shouldBe` "% Generated by jats2tex@0.11.1.0\n\\textbf{Hello}\n"
    it "handles nested XPaths" $ do
      doc <-
        parseJATS
          [here|
            <sec>
              <p>Something</p>
              <other><p>Hidden</p></other>
            </sec>
          |]
      templ <-
        parseTemplate
          "<noname>"
          [here|
            sec: |
              @@lua(return find("/p"))@@
          |]
      output <-
        jatsXmlToLaTeXText
          def {joInputDocument = doc, joTemplate = (templ, "<noname>")}
      output `shouldBe` "% Generated by jats2tex@0.11.1.0\nSomething\n"
    it "should find template" $ do
      templ <- parseTemplate "<noname>" [here|sec: "@@children"|]
      trees <-
        parseJATS
          [here|
            <sec>
              <p>Something</p>
            </sec>
          |]
      let doc = trees !! 0
      let findTemplateResult = findTemplate templ doc
      case findTemplateResult of
        Nothing -> expectationFailure "got nothing"
        Just (sub, ct, t) -> do
          templateSelector ct `shouldBe` "sec"
          templateContent ct `shouldBe` "@@children"
          templateHead ct `shouldBe` ""
