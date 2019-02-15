# Rubrik vCloud Director (vCD) Extensibility - Beta

Contains use case for VMware vCloud Director

## Use Cases

### Install Extension

* [Quick Start Guide](https://github.com/rubrikinc/rubrik-extension-for-vcd/blob/master/Install/quick-start.md)

## Contributing
We glady welcome contributions from the community. Currently this is only compiled code, but feel free to add issues and we'll jump on them!

* [Contributing Guide](https://github.com/rubrikinc/rubrik-extension-for-vcd/blob/master/CONTRIBUTING.md)

## License
* [MIT License](https://github.com/rubrikinc/rubrik-extension-for-vcd/blob/master/LICENSE)

## Beta Known Issues

* Moving back and forth between menus before previous calls finish, will present duplicate data
* Login form in use in settings until persistent credential storage has been implemented
* DNS Address for Reverse Proxy is hard-coded until action above is completed
* Upon completing File Restore, page refresh (f5) is required to fix the loading of the wizards
* Opening vApp Recovery after running File Restore will cause the form to crash

