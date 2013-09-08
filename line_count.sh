#!/bin/bash

find . \( ! -path ./Rapid\ Note/Utils/SS_PreferencePane/\* \) -a \( ! -path ./Rapid\ Note/Utils/APXML/\* \) -name "*.[hm]" -print0 | xargs -0 wc -l
