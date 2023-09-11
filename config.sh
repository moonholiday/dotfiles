#!/bin/bash

# Define the dotfiles directory
DOTFILES_DIR="$HOME/dotfiles"

# Define the list of directories you want to symlink, relative to the dotfiles directory
DIRECTORIES=("tmux" "zsh" "i3" "nvim")

# Function to create symlinks for a directory and its contents
create_symlinks() {
    local source_dir="$1"
    local destination_dir="$2"

    # Loop through the files and subdirectories in the source directory
    for item in "$source_dir"/*; do
        if [ -f "$item" ]; then
            local file_name=$(basename "$item")
            local source_file="$source_dir/$file_name"
            local destination_file="$destination_dir/$file_name"

            # Check if the destination file exists
            if [ -e "$destination_file" ]; then
                echo "Removing existing file: $destination_file"
                rm "$destination_file"
            fi

            # Create the symbolic link for the file
            echo "Creating symlink: $destination_file -> $source_file"
            ln -s "$source_file" "$destination_file"
        elif [ -d "$item" ]; then
            local subdir_name=$(basename "$item")
            local source_subdir="$source_dir/$subdir_name"
            local destination_subdir="$destination_dir/$subdir_name"

            # Check if the destination directory exists
            if [ -d "$destination_subdir" ]; then
                echo "Removing existing directory: $destination_subdir"
                rm -rf "$destination_subdir"
            fi

            # Create the symbolic link for the subdirectory and its contents
            echo "Creating symlink: $destination_subdir -> $source_subdir"
            ln -s "$source_subdir" "$destination_subdir"
        fi
    done
}

# Loop through the directories and create symlinks
for DIR in "${DIRECTORIES[@]}"; do
    SOURCE="$DOTFILES_DIR/$DIR"
    DESTINATION="$HOME/$DIR"

    create_symlinks "$SOURCE" "$DESTINATION"
done

