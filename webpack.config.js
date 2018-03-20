var webpack = require('webpack');
const path  = require('path');
const env   = require('yargs').argv.env;

let libPath         = path.resolve(__dirname, 'src')
let localBaseGLPath = path.join(__dirname, '../basegl/src')

let devtool = undefined
let aliases = {}
if (env == 'localdev') {
    aliases = {'basegl': localBaseGLPath};
    devtool = "eval-source-map";
}

module.exports =
  { entry:  ['./main.coffee']
  , context: libPath
  , output:
    { path: path.resolve(__dirname, 'dist', 'js')
    , publicPath: '/js/'
    , filename: 'bundle.js'
    , library: 'node_editor_basegl'
    , libraryTarget: 'umd'
    , strictModuleExceptionHandling: true
    }
  , node: 
    { __filename: true
    , __dirname:  true
    }
  , devtool: devtool
  , devServer:
    { contentBase: path.resolve(__dirname, 'dist')
    }
  , resolve: 
    { extensions: ['.js', '.coffee', '.glsl', '.vert', '.frag']
    , modules: 
      [ libPath
      , "node_modules"
      ]
    , alias: aliases 
    }
  , module:
    { strictExportPresence: true
    , rules:
      [ { test: /\.(coffee)$/
        , use:
          [ { loader: path.resolve('./basegl-loader.js')}
          , 'coffee-loader'
          ]
        }
      , { test: /\.(glsl|vert|frag)$/
        , use: 'raw-loader'
        , exclude: /node_modules/
        }
      , { test: /\.(glsl|vert|frag)$/
        , use: 'glslify-loader'
        , exclude: /node_modules/
        }
      ]
    }
  , plugins:
    [ new webpack.ProvidePlugin({'THREE': 'three'})
    ]

};
