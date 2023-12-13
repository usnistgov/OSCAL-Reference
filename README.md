# OSCAL-Reference

This repository houses the infrastructure for the OSCAL model generation pipeline.

## Usage

1. Clone the repository and initialize submodules:

```sh
git clone
cd OSCAL-Reference
git submodule update --init
```

- the OSCAL repository is quite large and when your internet connection is slow the default submodules init may take a while. Hence, to show progress on submodules init you may want to use the --progress option (available in git >= v2.11.0) in the following command:

```
git submodule update --init  --progress
```

2. Generate the site

```sh
make site
```

To see other common operations, refer to the [`Makefile`](./Makefile) or simply run `make help`.

### Local development

The target `make serve` runs builds the site dependencies and runs `hugo serve`.

### Speeding up the build

Some tasks such as generating the model documentation can be done in parallel for each target release.

Passing the `-j <number>` flag will allow for [parallel execution of makefile targets](https://www.gnu.org/software/make/manual/html_node/Parallel.html) and can significantly speed up build times.
Pass in an appropriate value (usually the core count of the current machine), e.x.:

```
make site -j 8
```
