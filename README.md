# Guppi

Guppi is a semi-autonomous coding assistant designed to facilitate and streamline your coding process.

GUPPI (or General Unit Primary Peripheral Interface) is from the Bobiverse series.

## Installation

```
make build
sudo make install
```

## Usage

Start by creating a `project.md` file and writing your project or feature specifications there. Being more descriptive yields better results. A convenient way to do this is to construct it in Chat GPT first. You may find it useful to follow a format similar to the one below, especially for new projects:

```
Project: guppi
Description: A semi-autonomous coding assistant.
Language: Crystal Lang
Dependencies: openai.cr

<Feature Specification>
```

To use guppi, run the following command in your terminal:

`guppi`

This command initiates Guppi. Guppi then generates the next task to complete, based on the project description in your `project.md` file, as well as the content of relevant files.

When you modify a file, Guppi will create a .edits.extension file and ask if you want to apply the changes.

By default gpt-4 is used. If you want to override and use another model like gpt-3.5-turbo-16k, use the -m flag:

```
guppi -m gpt-3.5-turbo-16k
```

## Development

To run Guppi during the development phase, use the following command:

```
crystal run src/guppi.cr
```

## Contributing

If you'd like to contribute to Guppi's development, follow these steps:

1. Fork it (<https://github.com/lancecarlson/guppi/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Lance Carlson](https://github.com/lancecarlson) - creator and maintainer
