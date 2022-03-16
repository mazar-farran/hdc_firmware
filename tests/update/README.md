# tests/endurance

This is used to perform a large number of updates to a target.  It creates three
versions of an update bundle and then iteratively updates the target.

## Base Requirements
* `python3`
* `python3-pip`
* `python3-venv`

## Getting Started
1. Setup a virtual environment.  From this directory:
    ```
    python3 -m venv .venv
    source .venv/bin/activate
    ```
2. Install dependencies.
    ```
    python3 -m pip install -r requirements.txt
    ```
3. See the program options.
    ```
    ./update.py --help 
    ```
4. Figure out the IP address of the target and run the program.
    ```
    ./update.py -t <IP_ADDRESS> -n <NUM_UPDATES>
    ```