# Guppi

A semi-autonomous coding assistant.

## Installation

```
make install
```

## Usage
To use guppi, run the following command in your terminal:

`guppi`

This will start guppi. Guppi will prompt you for the next task to complete based on the project description in your `project.md` file and the contents of relevant files. 

When modifying a file, guppi will create a .edits.extension file and ask if you want to apply the changes. 

## Development

```
crystal run src/guppi.cr
```

## Contributing

1. Fork it (<https://github.com/lancecarlson/guppi/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Lance Carlson](https://github.com/lancecarlson) - creator and maintainer