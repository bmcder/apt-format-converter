# apt-format-reverter
Converts the Deb822 format files (whether they have `.sources` or `.list` extension) to the legacy one-line format
PURPOSE: 

This script ensures all APT repository source files are in the correct format by converting any Deb822 format files (whether they have `.sources` or `.list` extension) to the traditional one-line format, while maintaining backups of the original files. 

  

# STEP-BY-STEP SETUP AND USAGE: 

1. Download the script:  

`sudo curl -L "https://github.com/bmcder/apt-format-converter/apt-format-reverter" -o $output_file /usr/local/bin/apt-format-reverter` 

2. Make it executable

`sudo chmod +x /usr/local/bin/apt-format-reverter` 

3. Run the script: 

`sudo /usr/local/bin/apt-format-reverter` 
  

# KEY FUNCTIONS: 

1. Backup: 

   - Creates a timestamped backup directory in `/var/tmp` 

   - Preserves the original directory structure and file permissions 

   - Stores original files before any modifications 

  

2. Format Detection and Conversion: 

   - Scans both `.sources` and `.list` files in `/etc/apt/sources.list.d/` 

   - Checks the main `/etc/apt/sources.list` file as well 

   - Identifies Deb822 format by checking for the `Types:` field 

   - Converts files to one-line format if necessary 

   - Changes `.sources` files to `.list` extension after conversion 

   - Preserves existing `.list` extension for files already using it 

  

3. Format Translation: 

   - Converts from Deb822 format: 

```
     Types: deb 

     URIs: http://example.com/ubuntu 

     Suites: jammy 

     Components: main restricted 
```
  

   - To traditional one-line format: 

  

   `deb http://example.com/ubuntu jammy main restricted`

  

  

# SAFETY FEATURES: 

- Creates backups before any modifications 

- Validates input format and types 

- Preserves comments and file structure 

- Provides clear error messages and warnings 

- Tracks and reports any errors during conversion 

- Only converts files that need conversion 

- Maintains correct file extensions 

  

# WHAT HAPPENS WHEN IT RUNS: 

1. Back up all source files (both `.sources` and `.list`) 

2. Check each file for correct format 

3. Convert any files in Deb822 format to one-line format 

4. Update file extensions as needed 

5. Display the backup location 

6. Provide instructions for reverting changes if needed 

  

TROUBLESHOOTING: 

If something goes wrong: 

1. Check the backup location shown in the script output 

2. Restore the original files: 
 

   `sudo cp -r /var/tmp/sources_backup_TIMESTAMP/* /` 

  

3. Run `sudo apt update` to verify the restoration 

  

The script is particularly useful for: 

- Converting newer Deb822 format files to traditional format 

- Fixing misconfigured `.list` files that accidentally use Deb822 format 

- Ensuring consistency across all APT source files 

- Migrating between different Ubuntu versions or tools with different format requirements 

  

IMPORTANT NOTES: 

- Always run with sudo privileges 

- Keep note of the backup directory path shown in the output 

- Check the output for any error messages 

- Run `sudo apt update` after the script completes to verify everything works 

- The script is idempotent - running it multiple times won't cause issues 

- Original files are safely backed up before any modifications 

 
