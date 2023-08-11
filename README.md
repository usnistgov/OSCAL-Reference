# OSCAL-Reference

This repository houses the infrastructure for the OSCAL model generation pipeline.

## Usage

1. Clone the repository and initialize submodules:

```sh
git clone
cd OSCAL-Reference
git submodule update --init
```

2. Generate the site

```sh
make site
```

To see other common operations, refer to the [`Makefile`](./Makefile) or simply run `make help`.

### Local development

The target `make serve` runs builds the site dependencies and runs `hugo serve`.

In some cases, this repository may be used to build documentation from a local copy of the OSCAL project, particularly in local branches, or a specific list of branches.  The branches and the OSCAL directory can be set from the command line to target specific changes:

- `REVISIONS` - the list of branches. Multiple branches can be separated with a space.
- `LOCAL_OSCAL_DIR` - the local path to the OSCAL repository.

To generate the site:

```sh
make site REVISIONS="feature-new-model" LOCAL_OSCAL_DIR="/My/Local/Code/OSCAL"
```

To serve the site locally (with two branches):

```sh
make serve REVISIONS="feature-new-model feature-new-model-2" LOCAL_OSCAL_DIR="/My/Local/Code/OSCAL"
```

### Speeding up the build

Some tasks such as generating the model documentation can be done in parallel for each target release.

Passing the `-j <number>` flag will allow for [parallel execution of makefile targets](https://www.gnu.org/software/make/manual/html_node/Parallel.html) and can significantly speed up build times.
Pass in an appropriate value (usually the core count of the current machine), e.x.:

```
make site -j 8
```
