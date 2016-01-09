#!/bin/bash

WorkingDir=`pwd`

mkdir -p ~/.vim/{autoload,after,bundle,skeletons}

# Copy pathogen
#
cp ${WorkingDir}/bundle/pathogen/autoload/pathogen.vim ~/.vim/autoload

# Copy the other plugins
#
for plugin in `ls -1 ${WorkingDir}/bundle`; do
    if [[ "${plugin}" != "pathogen" ]]; then
        cp -pr ${WorkingDir}/bundle/${plugin} ~/.vim/bundle
    fi
done

# Create symlinks to vimrc and gvimrc
#
ln -sf ${WorkingDir}/vimrc ~/.vimrc
ln -sf ${WorkingDir}/gvimrc ~/.gvimrc

