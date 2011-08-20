http = require 'http'
fs = require 'fs'
qs = require 'querystring'
url = require 'url'
{spawn, exec} = require 'child_process'

class Dunce
  constructor: (@callback, documentRoot) ->
    @documentRoot = documentRoot || process.cwd()
    fs.writeFileSync(Dunce.phpWrapName, Dunce.phpWrap)
    
    @server = http.createServer (req, res) =>
      @callback?(req, res)
      path = url.parse(req.url).pathname
      file = if path == '/' then "index.php" else path
      querystring = url.parse(req.url).query
      get = qs.parse(querystring)
      post = {}

      process = => @processPHP
        res: res, file: file,
        get: get, post: post,
        path: path.url,
        querystring: querystring

      if req.method == 'POST'
        postData = ''
        req.on 'data', (data) -> postData += data
        req.on 'end', =>
          post = qs.parse(postData)
          process()
      else
        process()

  listen: (@port) -> @server.listen(@port)

  buildPHPArray: (obj) ->
    code = "array("
    code += "'#{k}' => '#{v}'," for k,v of obj
    code += ");"

  processPHP: (args) ->
    try
      phpGet = @buildPHPArray args.get
      phpPost = @buildPHPArray args.post
      phpServer = @buildPHPArray
        'QUERY_STRING': args.querystring
        'SERVER_NAME': 'localhost'
        'SERVER_PORT': @port

      command = "php #{Dunce.phpWrapName}"
      command += " \"#{phpServer}\""
      command += " \"#{phpGet}\" \"#{phpPost}\""
      command += " \"'#{@documentRoot}/#{args.file}';\""
      exec command, (err, stdout, stderr) -> args.res.end stdout

    catch error
      args.res.statusCode = 404
      args.res.end()

  @phpWrapName: '/tmp/__wrap.php'

  @phpWrap: '''
    <?php
      $argv = $_SERVER['argv'];
      eval("\\$_SERVER = ".$argv[1]);
      eval("\\$_GET = ".$argv[2]);
      eval("\\$_POST = ".$argv[3]);
      eval("\\$__file = ".$argv[4]);
      require($__file);
    ?>
  '''

  @createServer: (callback, documentRoot) ->
    d = new Dunce(callback, documentRoot)

module.exports.Dunce = Dunce
