{ nixpkgs ? import <nixpkgs> {}, compiler ? "default" }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, base, haxl, hashable, exceptions, stdenv }:
      mkDerivation {
        pname = "haxl-test";
        version = "0.1.0.0";
        src = ./.;
        isLibrary = false;
        isExecutable = true;
        executableHaskellDepends = [ base haxl hashable exceptions ];
        license = stdenv.lib.licenses.bsd3;
      };

  haxl = { mkDerivation, aeson, base, binary, bytestring, containers
         , deepseq, exceptions, fetchgit, filepath, ghc-prim, hashable
         , HUnit, pretty, stdenv, test-framework, test-framework-hunit, text
         , time, transformers, unordered-containers, vector
         }:
    mkDerivation {
      pname = "haxl";
      version = "0.5.0.0";
      src = fetchgit {
        url = "git://github.com/facebook/Haxl.git";
        sha256 = "09vq1lprz3c50yzwlkwzr1wss494nwq0i5i63mnxnksxicxqzymp";
        rev = "b5821182cf520105f468b2397cf7bfdd4bc58f88";
      };
      isLibrary = true;
      isExecutable = true;
      libraryHaskellDepends = [
        aeson base binary bytestring containers deepseq exceptions filepath
        ghc-prim hashable HUnit pretty text time transformers
        unordered-containers vector
      ];
      executableHaskellDepends = [ base hashable time ];
      testHaskellDepends = [
        aeson base binary bytestring containers deepseq filepath hashable
        HUnit test-framework test-framework-hunit text unordered-containers
      ];
      homepage = "https://github.com/facebook/Haxl";
      description = "A Haskell library for efficient, concurrent, and concise data access";
      license = stdenv.lib.licenses.bsd3;
    };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  drv = haskellPackages.callPackage f {
    haxl = haskellPackages.callPackage haxl {};
  };

in

  if pkgs.lib.inNixShell then drv.env else drv
