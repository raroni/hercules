# Hercules

By mimicking node.js' `require`, Herluces lets you use your CommonJS packages in the browser. It even supports `packages.json` dependencies.

This enables you to develop and test your code server side, and bundle it for the browser later.

## How does it work?

```coffeescript
Hercules = require 'hercules'
bundle = Hercules.bundle '/path/to/my/package'
source = bundle.toString() # Returns a chunk of Javascript that defines this.require
```

Send `source` to the browser (for example via [express](http://expressjs.com/)). All code run after `source`, will have access to a `require` method.

If you don't want to attach `require` to `window` you can do like this:

```coffeescript
Hercules = require 'hercules'
bundle = Hercules.bundle '/path/to/my/package'
source = "
  (function() {
    #{bundle.toString()}
    window.MyAwesomeApp = require('.');
  })(window);
"
```

## Dependencies

Hercules automatically add dependencies defined in your `package.json` (read more about [package.json](http://wiki.commonjs.org/wiki/Packages/1.0)).

If you try to bundle a package that depends on a package that require node (defined in `package.json`'s `engines` field), Hercules will throw an error. If you instead want Hercules to just ignore these packages, you can use `ignore_node_packages` like this:

```coffeescript
Hercules = require 'hercules'
bundle = Hercules.bundle '/path/to/my/package', ignore_node_packages: true
source = bundle.toString()
```
