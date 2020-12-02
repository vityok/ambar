# Ambar

A primitive file server with a very simple Web UI meant to run in a
local network and serve files from a Raspberry Pi (or any other
Linux-based computer).

Written in Common Lisp, served by Hunchentoot, HTML is generated using
CL-WHO, filesystem is traversed using CL-FAD.

## License

MIT

## Running

Either clone repository or download a snapshot.

Then make it available for Quicklisp by following the ["local projects" mechanism](http://blog.quicklisp.org/2018/01/the-quicklisp-local-projects-mechanism.html). Or create a symlink to `ambar.asd` from the local-projects `directory`.

Launch your favorite Common Lisp (tested to work with SBCL and ECL,
but there is hardly a reason it won't work on CCL) and execute:

```lisp
;; load the package
(ql:quickload :ambar)

;; start Hunchentoot easy acceptor on default port 4242 and serve
;; files from the given directory
(ambar:run #"/home/user/Downloads/")
```

Now visit http://localhost:4242/dir (substitute for the real host name
or IP address).
