## D's settings pack
Some of my usual emacs settings for using with emacs live.

### TODO

![Image of Great Yak Shave!](https://raw.githubusercontent.com/djon3s/dzj-settings-emacs-live-pack/master/lib/yakshave8.png)
### init.el

### config

Files placed in the `config` dir may then be referenced and pulled into
your `init.el` via the fn `live-load-config-file`. For example, if you
have the file config/foo.el then you may load it in with:

    (live-load-config-file "foo.el")

### lib

 If you want to pull in external libraries into your pack, then you
 should place the libraries within the lib dir. To add a directory
 within the pack's lib directory to the Emacs load path (so that it's
 contents are available to require) you can use the fn
 `live-add-pack-lib`. For example, if you have the external library bar
 stored in lib which contains the file `baz.el` which you wish to
 require, this may be achieved by:

    (live-add-pack-lib "bar")
    (require 'baz)

 Have fun!
