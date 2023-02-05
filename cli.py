"""Console script for opencdms."""
import pathlib
import sys, os
import click
import yaml
import subprocess
from pathlib import Path
import socket

def _check_port(port)->bool:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(('localhost', port)) == 0


@click.group()
def main(args=None):
    """Console script for opencdms."""
    # See click documentation at https://click.palletsprojects.com/
    pass

@click.command(name="startdb")
def start_db():
    service_ports = [5432,9432,3306,35432,25432,23306,21521,35434,45432,35433,33308,33306,31521]
    occupied = False
    for port in service_ports:
        if _check_port(port):
            click.echo(f"########### Port {port} is in use by another service. Close the service and run again. #############")
            occupied = True
    if occupied and not click.confirm("Some ports are already in use by another service. Do you want to continue ?"):
        exit(1)
    
    docker_compose_file = f"{Path(__file__).parent}/docker-compose.yml"
    click.echo('starting databases....')
    out = subprocess.run(f"docker-compose -f {docker_compose_file} up -d",shell=True)
    if out.returncode != 0:
        click.echo("Start up not successfull")
        click.echo(out.stderr)
        click.echo("please close any conflicting ports")
    else:
        click.echo(out.stdout)
    click.echo("To stop running databases run: opencdms-test-data stopdb")
    return out.returncode

@click.command(name="stopdb")
def stop_db():
    docker_compose_file = f"{Path(__file__).parent}/docker-compose.yml"
    click.echo(docker_compose_file)
    out = subprocess.run(f"docker-compose -f {docker_compose_file} down", shell=True)

main.add_command(start_db)
main.add_command(stop_db)

if __name__ == "__main__":
    sys.exit(main())  # pragma: no cover
