#!/usr/bin/env bash
#
# Copyright (c) 2023 - for information on the respective copyright owner
# see the NOTICE file and/or the repository https://github.com/carbynestack/klyshko.
#
# SPDX-License-Identifier: Apache-2.0
#

# Fail, if any command fails
set -e

#######################################
# Retry a command up to a specific number of times until it exits successfully,
# with exponential back off.
#
# Copied from https://gist.github.com/sj26/88e1c6584397bb7c13bd11108a579746
# published under the "The Unlicense".
#
# Globals:
#   None
# Arguments:
#   The number of retries before giving up.
#   The command to execute, including any number of arguments.
# Outputs:
#   None
# Returns:
#   0 if command was executed successfully, status code of final failing
#   command execution otherwise.
#######################################
function retry {
  local retries=$1
  shift
  local count=0
  until "$@"; do
    exit=$?
    wait=$((2 ** count))
    count=$((count + 1))
    if [ $count -lt "$retries" ]; then
      echo "Retry $count/$retries exited $exit, retrying in $wait seconds..."
      sleep $wait
    else
      echo "Retry $count/$retries exited $exit, no more retries left."
      return $exit
    fi
  done
  return 0
}

# Setup offline executable command line arguments dictionary
# AVH: I don't know if binary triples for GF2N even make sense...
prime=$(cat /etc/kii/params/prime)
declare -A argsByType=(
  ["EDABIT_GFP_64"]="--field-type gfp --tuple-type edabits --edabit-width 64 --prime ${prime}"
  ["EDABIT_GFP_41"]="--field-type gfp --tuple-type edabits --edabit-width 41 --prime ${prime}"
  ["EDABIT_GFP_40"]="--field-type gfp --tuple-type edabits --edabit-width 40 --prime ${prime}"
  ["EDABIT_GFP_32"]="--field-type gfp --tuple-type edabits --edabit-width 32 --prime ${prime}"
  ["BINARY_TRIPLE_GFP"]="--field-type gfp --tuple-type btriples --prime ${prime}"
  ["DABIT_GFP"]="--field-type gfp --tuple-type dabits --prime ${prime}"
  ["DABIT_GF2N"]="--field-type gf2n --tuple-type dabits"
  ["BIT_GFP"]="--field-type gfp --tuple-type bits --prime ${prime}"
  ["BIT_GF2N"]="--field-type gf2n --tuple-type bits"
  ["INPUT_MASK_GFP"]="--field-type gfp --tuple-type triples --prime ${prime}"
  ["INPUT_MASK_GF2N"]="--field-type gf2n --tuple-type triples"
  ["INVERSE_TUPLE_GFP"]="--field-type gfp --tuple-type inverses --prime ${prime}"
  ["INVERSE_TUPLE_GF2N"]="--field-type gf2n --tuple-type inverses"
  ["SQUARE_TUPLE_GFP"]="--field-type gfp --tuple-type squares --prime ${prime}"
  ["SQUARE_TUPLE_GF2N"]="--field-type gf2n --tuple-type squares"
  ["MULTIPLICATION_TRIPLE_GFP"]="--field-type gfp --tuple-type triples --prime ${prime}"
  ["MULTIPLICATION_TRIPLE_GF2N"]="--field-type gf2n --tuple-type triples"
)
pn=${KII_PLAYER_NUMBER}
pc=${KII_PLAYER_COUNT}
fam=${KII_TUPLE_FAMILY}
# AVH: These might change in the future
declare -A binaryTypeShortByFamily=(
  ["CowGear"]="TT"
  ["Hemi"]="DB"
)
declare -A typeShortByFamily=(
  ["CowGear"]=""
  ["Hemi"]="D"
)
# This is staring to get ugly...
# AVH: I imagine 64/128 are prime length related, 40 for security parameter, so might need to do dynamically at some point
declare -A tupleFileByType=(
  ["EDABIT_GFP_64"]="${pc}-${typeShortByFamily[${fam}]}p-128/edaBits-64-P${pn}"
  ["EDABIT_GFP_41"]="${pc}-${typeShortByFamily[${fam}]}p-128/edaBits-41-P${pn}"
  ["EDABIT_GFP_40"]="${pc}-${typeShortByFamily[${fam}]}p-128/edaBits-40-P${pn}"
  ["EDABIT_GFP_32"]="${pc}-${typeShortByFamily[${fam}]}p-128/edaBits-32-P${pn}"
  ["BINARY_TRIPLE_GFP"]="${pc}-${binaryTypeShortByFamily[${fam}]}-64/Triples-${binaryTypeShortByFamily[${fam}]}-P${pn}"
  ["DABIT_GFP"]="${pc}-${typeShortByFamily[${fam}]}p-128/daBits-${typeShortByFamily[${fam}]}p-P${pn}"
  ["DABIT_GF2N"]="${pc}-${typeShortByFamily[${fam}]}2-40/daBits-${typeShortByFamily[${fam}]}2-P${pn}"
  ["BIT_GFP"]="${pc}-${typeShortByFamily[${fam}]}p-128/Bits-${typeShortByFamily[${fam}]}p-P${pn}"
  ["BIT_GF2N"]="${pc}-${typeShortByFamily[${fam}]}2-40/Bits-${typeShortByFamily[${fam}]}2-P${pn}"
  ["INPUT_MASK_GFP"]="${pc}-${typeShortByFamily[${fam}]}p-128/Triples-${typeShortByFamily[${fam}]}p-P${pn}"
  ["INPUT_MASK_GF2N"]="${pc}-${typeShortByFamily[${fam}]}2-40/Triples-${typeShortByFamily[${fam}]}2-P${pn}"
  ["INVERSE_TUPLE_GFP"]="${pc}-${typeShortByFamily[${fam}]}p-128/Inverses-${typeShortByFamily[${fam}]}p-P${pn}"
  ["INVERSE_TUPLE_GF2N"]="${pc}-${typeShortByFamily[${fam}]}2-40/Inverses-${typeShortByFamily[${fam}]}2-P${pn}"
  ["SQUARE_TUPLE_GFP"]="${pc}-${typeShortByFamily[${fam}]}p-128/Squares-${typeShortByFamily[${fam}]}p-P${pn}"
  ["SQUARE_TUPLE_GF2N"]="${pc}-${typeShortByFamily[${fam}]}2-40/Squares-${typeShortByFamily[${fam}]}2-P${pn}"
  ["MULTIPLICATION_TRIPLE_GFP"]="${pc}-${typeShortByFamily[${fam}]}p-128/Triples-${typeShortByFamily[${fam}]}p-P${pn}"
  ["MULTIPLICATION_TRIPLE_GF2N"]="${pc}-${typeShortByFamily[${fam}]}2-40/Triples-${typeShortByFamily[${fam}]}2-P${pn}"
)

declare -A actualCmdByFamily=(
  ["CowGear"]="klyshko-cowgear-offline.x"
  ["Hemi"]="klyshko-hemi-offline.x"
)

# Provide parameters in MP-SPDZ "Player-Data" folder.
# Note that we always provide parameters for both prime fields and fields of
# characteristic 2 regardless of the tuple type requested for reasons of simplicity.
declare fields=("p" "2")
for f in "${fields[@]}"
do

  [[ "$f" = "p" ]] && bit_width="128" || bit_width="40"
	folder="Player-Data/${KII_PLAYER_COUNT}-${typeShortByFamily[${fam}]}${f}-${bit_width}"
	mkdir -p "${folder}"
  echo "Providing parameters for field ${f}-${bit_width} in folder ${folder}"

  # Write MAC key share
  macKeyShareFile="${folder}/Player-MAC-Keys-${typeShortByFamily[${fam}]}${f}-P${KII_PLAYER_NUMBER}"
  macKeyShare=$(cat "/etc/kii/secret-params/mac_key_share_${f}")
  echo "${KII_PLAYER_COUNT} ${macKeyShare}" > "${macKeyShareFile}"
  echo "MAC key share for player ${KII_PLAYER_NUMBER} written to ${macKeyShareFile}"

done

# Write player file containing CRG service endpoints
playerFile="players"
for (( i=0; i<pc; i++ ))
do
  endpointEnvName="KII_PLAYER_ENDPOINT_${i}"
  echo ${!endpointEnvName}
done >> ${playerFile}

# Execute cowgear offline phase
# cmd="cowgear-offline.x --player ${KII_PLAYER_NUMBER} --number-of-parties ${KII_PLAYER_COUNT} --playerfile ${playerFile} --tuple-count ${KII_TUPLES_PER_JOB} ${argsByType[${KII_TUPLE_TYPE}]} ${KII_PLAYER_COUNT}"
cmd="${actualCmdByFamily[${fam}]} --player ${KII_PLAYER_NUMBER} --number-of-parties ${KII_PLAYER_COUNT} --playerfile ${playerFile} --tuple-count ${KII_TUPLES_PER_JOB} ${argsByType[${KII_TUPLE_TYPE}]} ${KII_PLAYER_COUNT}"
retries=${KII_RETRIES:-1}
retry "$retries" eval "$cmd"

# Copy generated tuples to path expected by KII
cp "Player-Data/${tupleFileByType[${KII_TUPLE_TYPE}]}" "${KII_TUPLE_FILE}"
