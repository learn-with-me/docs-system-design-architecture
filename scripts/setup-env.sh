#!/bin/bash
# Script to setup local virtual environment

virtualenv venv
source venv/bin/activate
pip3 install -r requirements.txt
mkdocs serve
