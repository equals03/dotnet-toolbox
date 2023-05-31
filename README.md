# dotnet-toolbox
A container image based on Fedora38 that includes the latest supported .NET SDKs, the corresponding ASP.NET runtimes, Mono and JetBrains Rider (license not included :P). It is used to isolate the development environment and provide everything required to develop .NET applications.

It was built to be used with [distrobox](https://github.com/89luca89/distrobox) due to its deep integration with the host OS.

## How to use

### Create from the registry
```sh
distrobox create --image ghcr.io/equals03/dotnet-toolbox --name dotnet-toolbox
distrobox enter dotnet-toolbox -- distrobox-export-all
```
... to automatically export the `Rider` app to the host.   
Additionally the `rider` binary will be exported to `~/.local/bin`.

To remove everything:
```sh
distrobox enter dotnet-toolbox -- distrobox-export-all --delete
```
### Oh also...
The binaries:
1. `docker`
2. `podman`  
... are symlinked to `distrobox-host-exec` so you should be able to control the host from within the toolbox.

## Building locally
... if you *really* want to:
```sh
podman build --tag dotnet-toolbox:latest --file Containerfile .
```

## Buyer beware
I will be updating/maintaining/adding to/removing from this image at any time according to MY needs.  
Bottom line: this is for me and I'll update it when I need/want too :) #saidwithlove

## Contributing
This is for my own personal use but contributions are welcome if the mood takes you. Please submit pull requests for new features or bug fixes.

## License
The image is licensed under the Apache License 2.0.