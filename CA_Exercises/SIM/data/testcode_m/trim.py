# Define the input and output file paths
input_file = "ori.txt"
output_file = "mult4_imem_content.txt"

# Open the input file for reading
with open(input_file, "r") as file:
    # Read the lines from the input file
    lines = file.readlines()

# Remove the "0x" prefix from each line and strip newline characters
modified_lines = [line.strip().replace("0x", "") for line in lines]

# Open the output file for writing
with open(output_file, "w") as file:
    # Write the modified lines to the output file without newline characters
    file.write("\n".join(modified_lines))

print("Text conversion completed. Output file: " + output_file)


