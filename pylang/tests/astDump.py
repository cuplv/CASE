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


def dump_ast_json_file(input_file: str, output_file: str = None, indent: int = 2) -> None:
    """
    Parse a Python file and dump its AST as JSON to a file.
    
    Args:
        input_file: Path to the Python source file
        output_file: Path to save the JSON output (default: input_file with .json extension)
        indent: Number of spaces for JSON indentation (default: 2)
    """
    if output_file is None:
        output_file = input_file.replace('.py', '.json')
    
    with open(input_file, 'r') as f:
        code = f.read()
    
    json_output = dump_ast_json(code, indent=indent)
    
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
