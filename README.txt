
This will run some tests to verify that ebtables is basically working.
It is far from complete but it's a start. It will use three virtual
machines, one as client, another as server and another as gateway,

It will need ssh as root without password from where you are running
this (another VM or hypervisor).

You can run specific tests doing:
    # make brouting

Or run all the tests:
    # make

No files need to be installed, but a bunch of configurations will be
changed in the VMs.

Enjoy!
fbl

