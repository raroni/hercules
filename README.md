# Hercules

By mimicking node.js' `require`, Herluces lets you use your CommonJS packages in the browser. It even supports `packages.json` dependencies.

This enables you to develop and test your code server side, and bundle it for the browser later.

The code examples below are written in [Coffeescript](http://coffeescript.org/) but plain Javascript will work too.

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

## Installation

Add `hercules` to your `package.json` and run `npm install`. Then you'll be able to do `require 'hercules'`.

## Dependencies

Hercules automatically add dependencies defined in your `package.json` (read more about [package.json](http://wiki.commonjs.org/wiki/Packages/1.0)).

If you try to bundle a package that depends on a package that require node (defined in `package.json`'s `engines` field), Hercules will throw an error. If you instead want Hercules to just ignore these packages, you can use `ignore_node_packages` like this:

```coffeescript
Hercules = require 'hercules'
bundle = Hercules.bundle '/path/to/my/package', ignore_node_packages: true
source = bundle.toString()
```

## Example

If you want to play with Hercules, I recommend checking out [this little example app](https://github.com/rasmusrn/hercules_example).

## Alternatives

Here's a list of other libraries that somehow enables you to use `require` in the browser.

### [Stitch](https://github.com/sstephenson/stitch)

Very elegant and simple! Unfortunately, it is based on load paths which makes its require behave different from node's. Written by one of my heroes, [Sam Stephenson](http://twitter.com/sstephenson).

### [Browserify](https://github.com/substack/node-browserify)

Mature solution with a lot of options and features. It doesn't handle dependencies however. It tries to do too many different things for my taste - but you might see this as an advantage.

### Other alternatives I haven't tried:

* [browser-require](https://github.com/rsms/browser-require)
* [browser-require](https://github.com/bnoguchi/browser-require) (another one with the same name)
* [brequire](https://github.com/weepy/brequire)