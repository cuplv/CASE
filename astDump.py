import ast
import json
from typing import Any, Dict, List, Union
import argparse


def ast_to_dict(node: ast.AST) -> Dict[str, Any]:
    """
    Convert an AST node to a dictionary representation.
    
    Args:
        node: An ast.AST node to convert
        
    Returns:
        A dictionary representation of the AST node
    """
    if not isinstance(node, ast.AST):
        return node
    
    result: Dict[str, Any] = {
        "type": node.__class__.__name__,
    }
    
    # Extract all fields from the AST node
    for field, value in ast.iter_fields(node):
        if isinstance(value, list):
            result[field] = [ast_to_dict(item) if isinstance(item, ast.AST) else item for item in value]
        elif isinstance(value, ast.AST):
            result[field] = ast_to_dict(value)
        else:
            result[field] = value
    
    return result


def parse_assertion_to_ast(assertion: str) -> Union[Dict[str, Any], None]:
    """
    Parse an assertion string as Python code and return its AST.
    
    Args:
        assertion: The assertion code (without the # comment marker)
        
    Returns:
        The AST dict if parsing succeeds, None otherwise
    """
    try:
        # Parse as a single expression
        tree = ast.parse(assertion, mode='eval')
        return ast_to_dict(tree.body)
    except SyntaxError:
        try:
            # If that fails, try parsing as statements
            tree = ast.parse(assertion)
            if tree.body:
                return ast_to_dict(tree.body[0])
        except SyntaxError:
            pass
    return None


def dump_ast_json(code: str, indent: int = 2) -> str:
    """
    Parse Python code and dump its AST as JSON.
    
    Args:
        code: Python source code to parse
        indent: Number of spaces for JSON indentation (default: 2)
        
    Returns:
        JSON string representation of the AST
    """
    tree = ast.parse(code)
    ast_dict = ast_to_dict(tree)
    return json.dumps(ast_dict, indent=indent)


def extract_assertion_comment(code: str) -> Union[str, None]:
    """
    Extract an assertion comment from the last line if it exists.
    Looks for lines starting with # followed by a symbolic expression.
    
    Args:
        code: Python source code
        
    Returns:
        The assertion string (without the #), or None if not found
    """
    lines = code.strip().split('\n')
    if not lines:
        return None
    
    last_line = lines[-1].strip()
    
    # Check if last line is a comment starting with #
    if last_line.startswith('#'):
        # Extract the comment content (everything after the # and leading spaces)
        assertion = last_line[1:].strip()
        if assertion:  # Make sure it's not empty
            return assertion
    
    return None


def dump_ast_json_file(input_file: str, output_file: str = None, indent: int = 2) -> None:
    """
    Parse a Python file and dump its AST as JSON to a file.
    If the last line is a comment, it will be parsed and added as an 'assertion' field on the root node.
    The assertion will include both the original string and its parsed AST.
    
    Args:
        input_file: Path to the Python source file
        output_file: Path to save the JSON output (default: input_file with .json extension)
        indent: Number of spaces for JSON indentation (default: 2)
    """
    if output_file is None:
        output_file = input_file + '.json'
    
    with open(input_file, 'r') as f:
        code = f.read()
    
    # Extract assertion comment if present
    assertion = extract_assertion_comment(code)
    
    # Parse code without the assertion comment line if it exists
    code_to_parse = code
    if assertion is not None:
        lines = code.strip().split('\n')
        code_to_parse = '\n'.join(lines[:-1])
    
    tree = ast.parse(code_to_parse)
    ast_dict = ast_to_dict(tree)
    
    # Add assertion field to root if found
    if assertion is not None:
        # Parse the assertion as Python code
        assertion_ast = parse_assertion_to_ast(assertion)
        ast_dict['assertion'] = {
            'string': assertion,
            'ast': assertion_ast
        }
    
    json_output = json.dumps(ast_dict, indent=indent)
    
    with open(output_file, 'w') as f:
        f.write(json_output)
    
    print(f"AST dumped to {output_file}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description ="parse python file's AST to json")
    parser.add_argument('-f', '--files', nargs='+', help="files")
    parser.add_argument('-i', '--input', action="store_true", help="input mode")
    args = parser.parse_args()
    files = args.files
    user_input = args.input
    
    if user_input:
        contents = []
        while True:
            try:
                line = input()
            except EOFError:
                break
            contents.append(line)
        code = '\n'.join(contents)
        print(dump_ast_json(code, indent=2))

    if files is not None:
        for file in files:
            try:
                print(f"Processing {file}...")
                dump_ast_json_file(file)
            except FileNotFoundError:
                print(f"File not found: {file}")
            except SyntaxError as e:
                print(f"Syntax error in {file}: {e}")
