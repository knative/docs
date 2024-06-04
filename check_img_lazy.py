import os
import sys
import subprocess
from bs4 import BeautifulSoup

def build_website():
    """Build the website using the specified command."""
    try:
        subprocess.check_call(['./hack/docker/test.sh'])  
    except subprocess.CalledProcessError as e:
        print(f"Website build failed: {e}")
        sys.exit(1)

def check_img_tags(base_dir):
    """Recursively check HTML files for <img> tags without the lazy loading attribute."""
    issues_found = False

    for root, _, files in os.walk(base_dir):
        for file in files:
            if file.endswith('.html'):
                file_path = os.path.join(root, file)
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    soup = BeautifulSoup(content, 'html.parser')
                    for img in soup.find_all('img'):
                        if 'loading' not in img.attrs or img.attrs['loading'] != 'lazy':
                            issues_found = True
                            line_number = find_line_number(content, img)
                            print(f"File: {file_path}, Line: {line_number}, Missing lazy loading: {img}")

    return issues_found

def find_line_number(content, tag):
    """Find the line number of the given tag in the content."""
    content_lines = content.splitlines()
    

    tag_attrs = {k: ' '.join(v) if isinstance(v, list) else v for k, v in tag.attrs.items()}
    
    for i, line in enumerate(content_lines):

        if all(str(attr) in line for attr in tag_attrs.values()):
            return i + 1
    
    return 'unknown'

if __name__ == "__main__":

    build_website()


    base_dir = 'site'  
    issues_found = check_img_tags(base_dir)


    if issues_found:
        sys.exit(1)
    else:
        print("All img tags have lazy loading attribute.")
        sys.exit(0)

