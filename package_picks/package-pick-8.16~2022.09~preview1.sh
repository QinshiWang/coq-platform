#!/usr/bin/env bash

###################### COPYRIGHT/COPYLEFT ######################

# (C) 2020..2022 Michael Soegtrop

# Released to the public under the
# Creative Commons CC0 1.0 Universal License
# See https://creativecommons.org/publicdomain/zero/1.0/legalcode.txt

###################### CONTROL VARIABLES #####################

# The two lines below are used by the package selection script
COQ_PLATFORM_VERSION_TITLE="Coq 8.16+rc1 (released Jun 2022) with a preview package pick for the 2022.09 release."
COQ_PLATFORM_VERSION_SORTORDER=9000

# The package list name is the final part of the opam switch name.
# It is usually either empty ot starts with ~.
# It might also be used for installer package names, but with ~ replaced by _
# It is also used for version specific file selections in the smoke test kit.
COQ_PLATFORM_PACKAGE_PICK_POSTFIX='~8.16+rc1~2022.09~preview1'

# The corresponding Coq development branch and tag
COQ_PLATFORM_COQ_BRANCH='v8.16'
COQ_PLATFORM_COQ_TAG='8.16+rc1'

# This controls if opam repositories for development packages are selected
COQ_PLATFORM_USE_DEV_REPOSITORY='Y'

# This extended descriptions is used for readme files
COQ_PLATFORM_VERSION_DESCRIPTION='This version of Coq Platform 2022.04.1 includes Coq 8.16+rc1 from Jun 2022. '
COQ_PLATFORM_VERSION_DESCRIPTION+='This is preview release with incomplete package pcisk and intended for package maintainers and early adopters. '

# The OCaml version to use for this pick (just the version number - options are elaborated in a platform dependent way)
COQ_PLATFORM_OCAML_VERSION='4.13.1'

###################### PACKAGE SELECTION #####################

PACKAGES=""

# - Comment out packages you do not want.
# - Packages which take a long time to build should be given last.
#   There is some evidence that they are built early then.
# - Versions ending with ~flex are identical to the opam package without the
#   ~flex extension, except that version restrictions have been relaxed.
# - The picking tracker issue is https://github.com/coq/platform/issues/193

########## BASE PACKAGES ##########

# The Coq compiler coqc and the Coq standard library
PACKAGES="${PACKAGES} coq.8.16+rc1"

########## IDE PACKAGES ##########

# GTK based IDE for Coq - alternatives are VSCoq and Proofgeneral for Emacs
if  [[ "${COQ_PLATFORM_EXTENT}"  =~ ^[iIfFxX] ]]
then
PACKAGES="${PACKAGES} coqide.8.16+rc1"
fi

########## "FULL" COQ PLATFORM PACKAGES ##########

if  [[ "${COQ_PLATFORM_EXTENT}"  =~ ^[fFxX] ]]
then
  # Some dependencies for which we need specific versions
  PACKAGES="${PACKAGES} PIN.sexplib0.v0.14.0"         # coq-serapi requires this version
  PACKAGES="${PACKAGES} PIN.ppxlib.0.25.1"            # coq-serapi requires this version

  # Standard library extensions
  PACKAGES="${PACKAGES} coq-bignums.8.16.0"
  PACKAGES="${PACKAGES} coq-ext-lib.0.11.6"
  PACKAGES="${PACKAGES} coq-stdpp.1.7.0"

  # General mathematics
  PACKAGES="${PACKAGES} coq-mathcomp-ssreflect.1.15.0"
  PACKAGES="${PACKAGES} coq-mathcomp-fingroup.1.15.0"
  PACKAGES="${PACKAGES} coq-mathcomp-algebra.1.15.0"
  PACKAGES="${PACKAGES} coq-mathcomp-solvable.1.15.0"
  PACKAGES="${PACKAGES} coq-mathcomp-field.1.15.0"
  PACKAGES="${PACKAGES} coq-mathcomp-character.1.15.0"
  PACKAGES="${PACKAGES} coq-mathcomp-bigenough.1.0.1"           # patched to allow Coq 8.16
  PACKAGES="${PACKAGES} coq-mathcomp-finmap.1.5.2"              # patched to allow Coq 8.16
  PACKAGES="${PACKAGES} coq-mathcomp-real-closed.1.1.3"
  PACKAGES="${PACKAGES} coq-mathcomp-zify.1.2.0+1.12+8.13"      # patched to allow Coq 8.16
  PACKAGES="${PACKAGES} coq-mathcomp-multinomials.1.5.5"        # patched to allow Coq 8.16 and ssreflect 1.15
  PACKAGES="${PACKAGES} coq-coquelicot.3.2.0"

  # Number theory
  PACKAGES="${PACKAGES} coq-coqprime.1.2.0"
  PACKAGES="${PACKAGES} coq-coqprime-generator.1.1.1"
  
  # Numerical mathematics
  PACKAGES="${PACKAGES} coq-flocq.4.1.0"
  # PACKAGES="${PACKAGES} coq-interval.4.5.1"                   # as of Jul 6th, the latest commit does not compile, checked August 8th
  PACKAGES="${PACKAGES} coq-gappa.1.5.2 gappa.1.4.1"

  # Constructive mathematics
  PACKAGES="${PACKAGES} coq-math-classes.8.15.0"                # patched to allow Coq 8.16
  PACKAGES="${PACKAGES} coq-corn.preview"                       # patched to latest commit on Jul 6th

  # Homotopy Type Theory (HoTT)
  PACKAGES="${PACKAGES} coq-hott.preview"                       # patched to latest commit on Jul 6th

  # Univalent Mathematics (UniMath)
  # Note: coq-unimath requires too much memory for 32 bit architectures
  if [ "${BITSIZE}" == "64" ]
  then
    PACKAGES="${PACKAGES} coq-unimath.preview"                  # patched to latest commit on Jul 6th
  fi 

  # Code extraction
  PACKAGES="${PACKAGES} coq-simple-io.1.7.0"                    # patched to allow Coq 8.16

  # Proof automation / generation / helpers
  PACKAGES="${PACKAGES} coq-menhirlib.20220210 menhir.20220210"
  PACKAGES="${PACKAGES} coq-equations.1.3+8.16"
  PACKAGES="${PACKAGES} coq-aac-tactics.8.16.0"
  PACKAGES="${PACKAGES} coq-unicoq.preview"                     # patched to latest commit on Jul 6th
  PACKAGES="${PACKAGES} coq-mtac2.preview"                      # as of Jul 6th, the latest commit does not compile, but an older commit does
  PACKAGES="${PACKAGES} coq-elpi.1.15.5 elpi.1.16.5"
  PACKAGES="${PACKAGES} coq-hierarchy-builder.1.3.0"
  PACKAGES="${PACKAGES} coq-quickchick.preview"                 # as of Jul 6th, the latest commit does not compile, but an older commit does
  # PACKAGES="${PACKAGES} coq-hammer-tactics.1.3.2+8.15"        # as of Jul 6th, the latest commit does not compile
  # if [[ "$OSTYPE" != cygwin ]]
  # then
  #   # coq-hammer does not work on Windows because it heavily relies on fork
  #   PACKAGES="${PACKAGES} coq-hammer.1.3.2+8.15"
  #   PACKAGES="${PACKAGES} eprover.2.6"
  #   PACKAGES="${PACKAGES} z3_tptp.4.8.14"
  # fi
  PACKAGES="${PACKAGES} coq-paramcoq.1.1.3+coq8.16"
  PACKAGES="${PACKAGES} coq-coqeal.1.1.1"                       # patched to allow coq-mathcomp-real-closed.preview
  PACKAGES="${PACKAGES} coq-libhyps.2.0.5"                      # patched to allow Coq 8.16
  PACKAGES="${PACKAGES} coq-itauto.8.16.0"

  # General mathematics (which requires one of the above tools)
  PACKAGES="${PACKAGES} coq-mathcomp-analysis.0.5.3"
  PACKAGES="${PACKAGES} coq-mathcomp-algebra-tactics.1.0.0"     # patched to allow Coq 8.16
  PACKAGES="${PACKAGES} coq-relation-algebra.preview"           # patched to latest commit on Jul 6th

  # Formal languages, compilers and code verification
  PACKAGES="${PACKAGES} coq-reglang.1.1.3"                      # patched to allow Coq 8.16 and mathcomp 1.15
  PACKAGES="${PACKAGES} coq-iris.3.6.0"                         # patched to allow Coq 8.16
  PACKAGES="${PACKAGES} coq-iris-heap-lang.3.6.0"
  PACKAGES="${PACKAGES} coq-ott.0.32"
  PACKAGES="${PACKAGES} ott.0.32"
  
  case "$COQ_PLATFORM_COMPCERT" in
    [yY]) PACKAGES="${PACKAGES} coq-compcert.3.11" ;;           # patched to allow Coq 8.16
    [nN]) true ;;
    *) echo "Illegal value for COQ_PLATFORM_COMPCERT - aborting"; false ;;
  esac

  case "$COQ_PLATFORM_VST" in
    [yY]) PACKAGES="${PACKAGES} coq-vst.2.10" ;;
    [nN]) true ;;
    *) echo "Illegal value for COQ_PLATFORM_VST - aborting"; false ;;
  esac

  # Proof analysis and other tools
  # PACKAGES="${PACKAGES} coq-dpdgraph.1.0+8.15"                # Error with latest commit: "dpdgraph is not a valid plugin name anymore"
fi

########## EXTENDED" COQ PLATFORM PACKAGES ##########

if  [[ "${COQ_PLATFORM_EXTENT}"  =~ ^[xX] ]]
then

  # Proof automation / generation / helpers
  PACKAGES="${PACKAGES} coq-deriving.0.1.0"                     # patched to allow Coq 8.16

  # General mathematics
  PACKAGES="${PACKAGES} coq-extructures.0.3.1"                  # patched to allow Coq 8.16 and mathcomp 1.15

  # Gallina extensions
  PACKAGES="${PACKAGES} coq-reduction-effects.0.1.4"
  PACKAGES="${PACKAGES} coq-record-update.0.3.0"                # patched to allow Coq 8.16

  # Communication with coqtop
  PACKAGES="${PACKAGES} coq-serapi.8.16+rc1+0.16.0"

  # Bedrock2, fiat crypto, ...
  PACKAGES="${PACKAGES} coq-coqutil.0.0.1"
  # PACKAGES="${PACKAGES} coq-bedrock2.0.0.1"                   # Error: "sed: illegal option -- z"
fi
