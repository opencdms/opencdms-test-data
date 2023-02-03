"""Console script for opencdms."""
import pathlib
import sys, os
import click
import yaml
import subprocess
from pathlib import Path
@click.group()
def main(args=None):
    """Console script for opencdms."""
    # See click documentation at https://click.palletsprojects.com/
    pass

@click.command(name="startdb")
def start_db():
    docker_compose_file = f"{Path(__file__).parent}/docker-compose.yml"
    print('starting databases....')
    out = subprocess.run(f"docker-compose -f {docker_compose_file} up -d",shell=True)
    if out.returncode != 0:
        print("Start up not successfull")
        print(out.stderr)
        print("please close any conflicting ports")
    else:
        print(out.stdout)
    print("To stop running databases run: opencdms-test-data stopdb")
    return out.returncode

@click.command(name="stopdb")
def stop_db():
    docker_compose_file = f"{Path(__file__).parent}/docker-compose.yml"
    print(docker_compose_file)
    out = subprocess.run(f"docker-compose -f {docker_compose_file} down", shell=True)

main.add_command(start_db)
main.add_command(stop_db)

if __name__ == "__main__":
    sys.exit(main())  # pragma: no cover
