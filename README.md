# Airbag Recall Checking API

This is a Rails server with one endpoint, takes a license plate
and checks whether an airbag recall has been issued for the vehicle.
It scrapes https://www.airbagrecall.com/en/check-your-vehicle to
get its results, which it exposes via JSON.

## Deployment

The accompanying Vagrantfile will set up an AWS EC2 instance running
the current code. Run it with `vagrant up --provider=aws`.
