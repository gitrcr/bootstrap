import os
import subprocess

# --- Configuration ---
FIXED_PATH = "./environment"  # <--- YOUR FIXED AND CORRECT PATH HERE

def print_selection(directory_name):
    """Prints the name of the selected directory to the screen."""
    print(f"\n>>> SELECTED DIRECTORY: {directory_name}")

def run_terraform_validate(full_path):
    """Executes 'terraform validate' and returns True if successful."""
    print(f"\nRunning 'terraform validate' in: {full_path}...")
    
    try:
        result = subprocess.run(
            ["terraform", "validate"],
            cwd=full_path,
            capture_output=True,
            text=True
        )
        
        if result.stdout:
            print("Output:\n", result.stdout)
        if result.stderr:
            print("Errors/Warnings:\n", result.stderr)
            
        return result.returncode == 0
            
    except FileNotFoundError:
        print("Error: 'terraform' command not found.")
        return False
    except Exception as e:
        print(f"Unexpected error: {e}")
        return False

def run_terraform_apply(full_path):
    """Executes 'terraform apply -auto-approve' in the specified path."""
    print(f"\nRunning 'terraform apply -auto-approve' in: {full_path}...")
    
    try:
        result = subprocess.run(
            ["terraform", "apply", "-auto-approve"],
            cwd=full_path,
            capture_output=True,
            text=True
        )
        
        if result.stdout:
            print("Apply Output:\n", result.stdout)
        if result.stderr:
            print("Apply Errors:\n", result.stderr)
            
        if result.returncode == 0:
            print("Terraform apply completed successfully!")
        else:
            print(f"Apply failed (Code: {result.returncode}).")
            
    except FileNotFoundError:
        print("Error: 'terraform' command not found.")
    except Exception as e:
        print(f"Unexpected error during apply: {e}")

def run_terraform_destroy(full_path):
    """Executes 'terraform destroy -auto-approve' in the specified path."""
    print(f"\nRunning 'terraform destroy -auto-approve' in: {full_path}...")
    
    try:
        result = subprocess.run(
            ["terraform", "destroy", "-auto-approve"],
            cwd=full_path,
            capture_output=True,
            text=True
        )
        
        if result.stdout:
            print("Destroy Output:\n", result.stdout)
        if result.stderr:
            print("Destroy Errors:\n", result.stderr)
            
        if result.returncode == 0:
            print("Terraform destroy completed successfully!")
        else:
            print(f"Destroy failed (Code: {result.returncode}).")
            
    except FileNotFoundError:
        print("Error: 'terraform' command not found.")
    except Exception as e:
        print(f"Unexpected error during destroy: {e}")

def ask_confirmation():
    """Asks for yes/y or no/n confirmation. Returns True if affirmative."""
    while True:
        response = input("\nDo you want to apply the configuration? (yes/y or no/n): ").strip().lower()
        
        if response in ['yes', 'y']:
            return True
        elif response in ['no', 'n']:
            return False
        else:
            print("Invalid input. Please answer 'yes', 'y', 'no', or 'n'.")

def ask_action_type():
    """Asks whether to 'apply' or 'destroy'. Returns the chosen action."""
    while True:
        response = input("\nSelect action [apply/destroy]: ").strip().lower()
        
        if response in ['apply', 'a']:
            return 'apply'
        elif response in ['destroy', 'd']:
            return 'destroy'
        else:
            print("Invalid input. Please answer 'apply' or 'destroy'.")

def select_directory(path):
    # Direct list without existence checks (assuming correct path)
    elements_list = os.listdir(path)

    while True:
        # 1. Show numbered list
        print("\n--- List ---")
        for i, item in enumerate(elements_list, start=1):
            print(f"{i}. {item}")
        
        # 2. Request input
        entry = input(f"\nSelect a number (1-{len(elements_list)}): ")

        # 3. Validate ONLY numeric input
        if not entry.isdigit():
            print("Error: You must enter a number.")
            continue

        number = int(entry)

        if 1 <= number <= len(elements_list):
            element = elements_list[number - 1]
            full_path = os.path.join(path, element)
            
            print_selection(element)
            
            # Bifurcation: Ask for action type
            action = ask_action_type()
            
            if action == 'apply':
                # Existing Apply Logic
                if run_terraform_validate(full_path):
                    if ask_confirmation():
                        run_terraform_apply(full_path)
                    else:
                        print("\nApply operation cancelled by user.")
                else:
                    print("\nValidation failed. Apply will not be requested.")
            
            elif action == 'destroy':
                # New Destroy Logic
                # Optional: You might want a confirmation here too, 
                # but per request, we execute the command directly.
                print("\nExecuting destroy operation...")
                run_terraform_destroy(full_path)
            
            return element
        else:
            print(f"Error: Number out of range (1-{len(elements_list)}).")

# Execution
if __name__ == "__main__":
    select_directory(FIXED_PATH)   