#!/bin/bash

# Define the menu options
options=("mult2" "mult3" "mult4" "exit")

# Define a function to display the menu and prompt for user input
show_menu() {
    echo "Select an option:"
    for i in "${!options[@]}"; do
        echo "$i. ${options[$i]}"
    done
}

# Define a function to run the selected code
run_code() {
    case $1 in
        0) # Run mult2 code
            echo "Running mult2 code..."
            cat data/testcode_m/mult2_imem_content.txt > data/imem_content.txt
            cat data/testcode_m/mult2_dmem_content.txt > data/dmem_content.txt
            make nc
            ;;
        1) # Run mult3 code
            echo "Running mult3 code..."
            cat data/testcode_m/mult3_imem_content.txt > data/imem_content.txt
            cat data/testcode_m/mult3_dmem_content.txt > data/dmem_content.txt
            make nc
            ;;
        2) # Run mult4 code
            echo "Running mult4 code..."
            cat data/testcode_m/mult4_imem_content.txt > data/imem_content.txt
            cat data/testcode_m/mult4_dmem_content.txt > data/dmem_content.txt
            make nc
            ;;
        3) # Exit the program
            echo "Exiting..."
            make clean
            exit 0
            ;;
        *) # Invalid selection
            echo "Invalid option. Please try again."
            ;;
    esac
}

# Loop to display the menu and prompt for user input
while true; do
    show_menu
    read -p "Enter your selection: " choice
    run_code $choice
done
