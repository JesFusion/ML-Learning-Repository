import os

def comment_file(input_filename):
    """
    Reads a file and comments out every line. 
    If a comment already exists, it appends '...' to the existing hashtag.
    Preserves all leading spaces/indentation.
    """
    # Check if the input file actually exists
    if not os.path.isfile(input_filename):
        print(f"Error: The file '{input_filename}' does not exist.")
        return

    # Generate the new output filename so we don't destroy the original
    base_name = os.path.basename(input_filename)
    directory = os.path.dirname(input_filename)
    output_filename = os.path.join(directory, f"commented_{base_name}")

    try:
        # Read the original lines
        with open(input_filename, 'r', encoding='utf-8') as infile:
            lines = infile.readlines()

        # Process and write the lines
        with open(output_filename, 'w', encoding='utf-8') as outfile:
            for line in lines:
                # Remove spaces from the left side to check the actual text
                stripped_line = line.lstrip()
                
                # If the line is completely empty (or just spaces/newlines), leave it alone
                if not stripped_line:
                    outfile.write(line)
                    continue
                
                # Figure out exactly what the leading spaces are
                leading_spaces_length = len(line) - len(stripped_line)
                leading_spaces = line[:leading_spaces_length]

                # Check if the text starts with a comment
                if stripped_line.startswith('#'):
                    # Replace the first '#' with '#...' and keep the rest of the line
                    new_line = leading_spaces + '#...' + stripped_line[1:]
                else:
                    # Add '# ' before the code, maintaining the original indentation
                    new_line = leading_spaces + '# ' + stripped_line
                
                outfile.write(new_line)

        print(f"Success! Commented file saved as:\n{output_filename}")

    except Exception as e:
        print(f"An error occurred while processing the file: {e}")

if __name__ == "__main__":
    # ---------------------------------------------------------
    # Pass the filename directly here as a string.
    # Replace "your_file_name.py" with your actual file path!
    # ---------------------------------------------------------
    file_to_comment = ""
        
    # Run the function
    if file_to_comment.strip():
        comment_file(file_to_comment)
    else:
        print("No filename provided. Exiting.")