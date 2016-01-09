#l!/bin/bash

WorkingDir=`pwd`

mkdir -p ~/bin

ln -sf ${WorkingDir}/mintty-colors-solarized/sol.dark ~/bin/mintty-colors-solarized.dark
ln -sf ${WorkingDir}/mintty-colors-solarized/sol.light ~/bin/mintty-colors-solarized.light
ln -sf ~/bin/mintty-colors-solarized.dark ~/bin/mintty-colors-solarized
