(function() {
  var Dunce, exec, fs, http, qs, spawn, url, _ref;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  http = require('http');
  fs = require('fs');
  qs = require('querystring');
  url = require('url');
  _ref = require('child_process'), spawn = _ref.spawn, exec = _ref.exec;
  Dunce = (function() {
    function Dunce(callback, documentRoot) {
      this.callback = callback;
      this.documentRoot = documentRoot || process.cwd();
      fs.writeFileSync(Dunce.phpWrapName, Dunce.phpWrap);
      this.server = http.createServer(__bind(function(req, res) {
        var file, get, path, post, postData, process, querystring;
        if (typeof this.callback === "function") {
          this.callback(req, res);
        }
        path = url.parse(req.url).pathname;
        file = path === '/' ? "index.php" : path;
        querystring = url.parse(req.url).query;
        get = qs.parse(querystring);
        post = {};
        process = __bind(function() {
          return this.processPHP({
            res: res,
            file: file,
            get: get,
            post: post,
            path: path.url,
            querystring: querystring
          });
        }, this);
        if (req.method === 'POST') {
          postData = '';
          req.on('data', function(data) {
            return postData += data;
          });
          return req.on('end', __bind(function() {
            post = qs.parse(postData);
            return process();
          }, this));
        } else {
          return process();
        }
      }, this));
    }
    Dunce.prototype.listen = function(port) {
      this.port = port;
      return this.server.listen(this.port);
    };
    Dunce.prototype.buildPHPArray = function(obj) {
      var code, k, v;
      code = "array(";
      for (k in obj) {
        v = obj[k];
        code += "'" + k + "' => '" + v + "',";
      }
      return code += ");";
    };
    Dunce.prototype.processPHP = function(args) {
      var command, phpGet, phpPost, phpServer;
      try {
        phpGet = this.buildPHPArray(args.get);
        phpPost = this.buildPHPArray(args.post);
        phpServer = this.buildPHPArray({
          'QUERY_STRING': args.querystring,
          'SERVER_NAME': 'localhost',
          'SERVER_PORT': this.port
        });
        command = "php " + Dunce.phpWrapName;
        command += " \"" + phpServer + "\"";
        command += " \"" + phpGet + "\" \"" + phpPost + "\"";
        command += " \"'" + this.documentRoot + "/" + args.file + "';\"";
        return exec(command, function(err, stdout, stderr) {
          return args.res.end(stdout);
        });
      } catch (error) {
        args.res.statusCode = 404;
        return args.res.end();
      }
    };
    Dunce.phpWrapName = '/tmp/__wrap.php';
    Dunce.phpWrap = '<?php\n  $argv = $_SERVER[\'argv\'];\n  eval("\\$_SERVER = ".$argv[1]);\n  eval("\\$_GET = ".$argv[2]);\n  eval("\\$_POST = ".$argv[3]);\n  eval("\\$__file = ".$argv[4]);\n  require($__file);\n?>';
    Dunce.createServer = function(callback, documentRoot) {
      var d;
      return d = new Dunce(callback, documentRoot);
    };
    return Dunce;
  })();
  module.exports.Dunce = Dunce;
}).call(this);
