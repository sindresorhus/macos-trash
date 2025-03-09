# macos-trash

> Move files and folders to the trash

*Requires macOS 10.13 or later.*

Since macOS 14, there is now a built-in `trash` command. The benefit of the binary here is that it has a `--interactive` flag.

## Install

###### [Homebrew](https://brew.sh)

```sh
brew install macos-trash
```

###### [Mint](https://github.com/yonaskolb/Mint)

```sh
mint install sindresorhus/macos-trash
```

###### Manually

[Download](https://github.com/sindresorhus/macos-trash/releases/latest) the binary and put it in `/usr/local/bin`.

## Usage

```sh
trash [--help | -h] [--version | -v] [--interactive | -i] <path> […]
```

## Build

```sh
./build
```

## Related

- [trash](https://github.com/sindresorhus/trash) - Cross-platform Node.js version
- [empty-trash](https://github.com/sindresorhus/empty-trash) - Empty the trash
- [macos-wallpaper](https://github.com/sindresorhus/macos-wallpaper) - Manage the desktop wallpaper
- [do-not-disturb](https://github.com/sindresorhus/do-not-disturb) - Control the macOS `Do Not Disturb` feature
- [More…](https://github.com/search?q=user%3Asindresorhus+language%3Aswift+archived%3Afalse&type=repositories)
